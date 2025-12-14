local M = {}

-- Mapping workspace names to directories
local WORKSPACE_MAP = {
  ["@g2b/admin"] = "apps/admin",
  ["@g2b/main"] = "apps/main",
  ["@g2b/judges"] = "apps/judges",
  ["@g2b/touch"] = "apps/touch",
  ["@g2b/mediabank"] = "apps/mediabank",
  ["@g2b/shared"] = "packages/shared",
}

-- Normalize path with workspace consideration
local function normalize_path(file_path, workspace_name, cwd)
  file_path = file_path:gsub("^%s+", ""):gsub("%s+$", "")

  -- If workspace name exists, search for file in corresponding directory
  if workspace_name then
    local workspace_dir = WORKSPACE_MAP[workspace_name]
    if workspace_dir then
      local full_path = cwd .. "/" .. workspace_dir .. "/" .. file_path
      full_path = vim.fn.fnamemodify(full_path, ":p")
      if vim.fn.filereadable(full_path) == 1 then
        return full_path
      end
    end
  end

  -- If path doesn't start with /, make it absolute relative to cwd
  if not (file_path:match("^/") or file_path:match("^%a:")) then
    file_path = vim.fn.fnamemodify(cwd .. "/" .. file_path, ":p")
  else
    file_path = vim.fn.fnamemodify(file_path, ":p")
  end
  return file_path
end

-- Validate data before adding to quickfix
local function validate_and_add(qf_list, file, lnum, col_num, text)
  -- Check if file exists
  if vim.fn.filereadable(file) ~= 1 then
    return false
  end

  -- Check line number validity
  if not lnum or lnum < 1 then
    return false
  end

  -- Read file completely to check size
  local ok, lines = pcall(vim.fn.readfile, file)
  if not ok or not lines then
    return false
  end

  local file_lines = #lines
  if file_lines == 0 then
    return false
  end

  -- Adjust line number if it's out of bounds
  if lnum > file_lines then
    lnum = file_lines
  end

  -- Check column validity
  local line_content = lines[lnum] or ""
  local line_length = #line_content
  col_num = col_num or 1

  -- Column must be within line bounds (1-based, but can be 1 more for end of line)
  if col_num < 1 then
    col_num = 1
  elseif col_num > line_length + 1 then
    col_num = math.max(1, line_length)
  end

  -- Clean text from extra characters
  local clean_text = (text or ""):gsub("^%s+", ""):gsub("%s+$", "")
  if clean_text == "" then
    clean_text = "Lint error"
  end

  -- Ensure all values are valid
  if lnum >= 1 and lnum <= file_lines and col_num >= 1 and col_num <= line_length + 1 then
    table.insert(qf_list, {
      filename = file,
      lnum = lnum,
      col = col_num,
      text = clean_text,
    })
    return true
  end

  return false
end

-- Parse error line in format @g2b/admin:lint-ts: file.tsx(84,27): error TS2339: message
-- or @g2b/admin:lint: file.tsx(84,27): error message
local function parse_workspace_error(line, cwd)
  -- Format: @g2b/admin:lint-ts: src/file.tsx(84,27): error TS2339: message
  local workspace, file, line_num, col, message =
    line:match("@g2b/([^:]+):lint%-ts:%s+(.-)%((%d+),(%d+)%):%s+error[^:]*:%s*(.+)$")
  if workspace and file and line_num then
    file = normalize_path(file:gsub("%s+$", ""), "@g2b/" .. workspace, cwd)
    local lnum = tonumber(line_num)
    local col_num = tonumber(col) or 1
    return file, lnum, col_num, message:gsub("^%s+", ""):gsub("%s+$", "")
  end

  -- Format: @g2b/admin:lint: src/file.tsx(84,27): error message
  workspace, file, line_num, col, message = line:match("@g2b/([^:]+):lint:%s+(.-)%((%d+),(%d+)%):%s+(.+)$")
  if workspace and file and line_num then
    file = normalize_path(file:gsub("%s+$", ""), "@g2b/" .. workspace, cwd)
    local lnum = tonumber(line_num)
    local col_num = tonumber(col) or 1
    return file, lnum, col_num, message:gsub("^%s+", ""):gsub("%s+$", "")
  end

  return nil
end

-- Parse error line in other formats
local function parse_other_formats(line, cwd)
  -- Format: file.ts(123,45): error TS1234: message
  local file, line_num, col, message = line:match("^([^(]+)%((%d+),(%d+)%):%s*(.+)$")
  if file and line_num then
    file = normalize_path(file, nil, cwd)
    local lnum = tonumber(line_num)
    local col_num = tonumber(col) or 1
    return file, lnum, col_num, (message or line):gsub("^%s+", ""):gsub("%s+$", "")
  end

  -- Format: file.ts:123:45: error message
  file, line_num, col, message = line:match("^([^:]+):(%d+):(%d+):%s*(.+)$")
  if file and line_num then
    file = normalize_path(file, nil, cwd)
    local lnum = tonumber(line_num)
    local col_num = tonumber(col) or 1
    return file, lnum, col_num, (message or line):gsub("^%s+", ""):gsub("%s+$", "")
  end

  -- Format: file.ts:123: error message (without column)
  file, line_num, message = line:match("^([^:]+):(%d+):%s*(.+)$")
  if file and line_num then
    file = normalize_path(file, nil, cwd)
    local lnum = tonumber(line_num)
    return file, lnum, 1, (message or line):gsub("^%s+", ""):gsub("%s+$", "")
  end

  return nil
end

-- Parse all output lines
local function parse_output(output_lines, cwd)
  local qf_list = {}
  local pending_file = nil

  for _, line in ipairs(output_lines) do
    if not line or line == "" then
      goto continue
    end

    -- Skip turbo/yarn service lines
    if
      (
        line:match("^yarn run")
        or line:match("^%$ turbo")
        or line:match("^• ")
        or line:match("^Running lint%-ts")
        or line:match("^Running lint")
        or line:match("Packages in scope")
        or line:match("Remote caching")
      )
      and not line:match(":%d+:%d+")
      and not line:match(":%d+%s+-%s+error")
      and not line:match("^%s+%d+:%d+")
    then
      goto continue
    end

    -- Skip "cache bypass" lines only if they don't contain errors
    if
      line:match("cache bypass")
      and not line:match(":%d+:%d+")
      and not line:match(":%d+%s+-%s+error")
      and not line:match("^%s+%d+:%d+")
    then
      goto continue
    end

    -- Format: @g2b/shared:lint: /path/to/file.tsx
    -- Next line can be: @g2b/shared:lint:   3:10  error  message
    -- Or simply:   3:10  error  message
    local workspace, file_path = line:match("@g2b/([^:]+):lint(-ts)?:%s+(.+)$")
    if workspace and file_path then
      -- Check if this is an error line (contains numbers:numbers error)
      -- Format: @g2b/shared:lint:   3:10  error  message
      local line_num, col, message = file_path:match("^%s*(%d+):(%d+)%s+error%s+(.+)$")
      if line_num and pending_file then
        -- This is an error line
        local lnum = tonumber(line_num)
        local col_num = tonumber(col) or 1
        validate_and_add(qf_list, pending_file, lnum, col_num, message:gsub("^%s+", ""):gsub("%s+$", ""))
        pending_file = nil
        goto continue
      end

      -- Without column: @g2b/shared:lint:   3  error  message
      line_num, message = file_path:match("^%s*(%d+)%s+error%s+(.+)$")
      if line_num and pending_file then
        local lnum = tonumber(line_num)
        validate_and_add(qf_list, pending_file, lnum, 1, message:gsub("^%s+", ""):gsub("%s+$", ""))
        pending_file = nil
        goto continue
      end

      -- If this is not an error, it's a file path
      -- Normalize path
      file_path = file_path:gsub("^%s+", ""):gsub("%s+$", "")
      -- If path is absolute, use it, otherwise normalize
      if file_path:match("^/") or file_path:match("^%a:") then
        file_path = vim.fn.fnamemodify(file_path, ":p")
      else
        file_path = normalize_path(file_path, "@g2b/" .. workspace, cwd)
      end
      pending_file = file_path
      goto continue
    end

    -- If there's a pending_file, parse error line
    if pending_file then
      -- Format: @g2b/shared:lint:   3:10  error  message
      local workspace2, line_num, col, message = line:match("@g2b/([^:]+):lint:%s+(%d+):(%d+)%s+error%s+(.+)$")
      if workspace2 and line_num then
        local lnum = tonumber(line_num)
        local col_num = tonumber(col) or 1
        validate_and_add(qf_list, pending_file, lnum, col_num, message:gsub("^%s+", ""):gsub("%s+$", ""))
        pending_file = nil
        goto continue
      end

      -- Format:   3:10  error  message (without prefix)
      local line_num, col, message = line:match("^%s+(%d+):(%d+)%s+error%s+(.+)$")
      if line_num then
        local lnum = tonumber(line_num)
        local col_num = tonumber(col) or 1
        validate_and_add(qf_list, pending_file, lnum, col_num, message:gsub("^%s+", ""):gsub("%s+$", ""))
        pending_file = nil
        goto continue
      end

      -- Without column: @g2b/shared:lint:   3  error  message
      workspace2, line_num, message = line:match("@g2b/([^:]+):lint:%s+(%d+)%s+error%s+(.+)$")
      if workspace2 and line_num then
        local lnum = tonumber(line_num)
        validate_and_add(qf_list, pending_file, lnum, 1, message:gsub("^%s+", ""):gsub("%s+$", ""))
        pending_file = nil
        goto continue
      end

      -- Without column:   3  error  message (without prefix)
      line_num, message = line:match("^%s+(%d+)%s+error%s+(.+)$")
      if line_num then
        local lnum = tonumber(line_num)
        validate_and_add(qf_list, pending_file, lnum, 1, message:gsub("^%s+", ""):gsub("%s+$", ""))
        pending_file = nil
        goto continue
      end

      -- If line starts with @g2b and it's not an error, it's a new file, reset pending_file
      if line:match("^@g2b/") and not line:match("error") then
        pending_file = nil
      end
    end

    -- Parse errors in workspace format (lint-ts)
    local file, lnum, col_num, message = parse_workspace_error(line, cwd)
    if file and lnum then
      validate_and_add(qf_list, file, lnum, col_num, message)
      goto continue
    end

    -- Parse errors in other formats
    file, lnum, col_num, message = parse_other_formats(line, cwd)
    if file and lnum then
      validate_and_add(qf_list, file, lnum, col_num, message)
      goto continue
    end

    ::continue::
  end

  return qf_list
end

-- Run linting and process results
function M.run_lint()
  local cwd = vim.fn.getcwd()

  -- check if we're in a project directory (search for package.json in current directory or above)
  local function find_package_json(dir)
    local package_json = dir .. "/package.json"
    if vim.fn.filereadable(package_json) == 1 then
      return true
    end
    -- check parent directory
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then
      -- reached filesystem root
      return false
    end
    return find_package_json(parent)
  end

  if not find_package_json(cwd) then
    vim.notify("it's not a project directory", vim.log.levels.warn, { title = "linting" })
    return
  end

  local output_lines = {}
  local jobs_completed = 0
  local total_jobs = 2
  local is_completed = false
  local update_timer = nil
  local spinner_frame = 0
  -- use fixed id for all loading notifications
  local loading_notification_id = "lint_loading"

  -- spinner animation: dots move left to right and back
  local spinner_frames = {
    "", -- no dots
    ".", -- one dot on left
    "..", -- two dots on left
    "...", -- three dots
    " ..", -- two dots on right
    "  .", -- one dot on right
  }

  -- function to update loading notification with spinner animation
  local function update_loading_notification()
    if not is_completed then
      -- update animation frame (0-5, then back to 0)
      spinner_frame = (spinner_frame + 1) % #spinner_frames
      local spinner = spinner_frames[spinner_frame + 1] -- lua indexing starts at 1
      local message = "project linting " .. spinner

      -- show new notification with fixed id to replace previous one
      vim.schedule(function()
        vim.notify(message, vim.log.levels.info, {
          timeout = 1000,
          title = "loading",
          id = loading_notification_id, -- use fixed id
        })
      end)
    end
  end

  -- show first loading notification
  spinner_frame = 0
  vim.notify("project linting " .. spinner_frames[1], vim.log.levels.info, {
    timeout = 1000,
    title = "loading",
    id = loading_notification_id, -- use fixed id
  })

  -- create timer for periodic updates (every 200ms for smooth animation)
  update_timer = vim.loop.new_timer()
  update_timer:start(200, 200, function()
    if not is_completed then
      update_loading_notification()
    else
      -- stop timer if task is completed
      update_timer:stop()
      update_timer:close()
      update_timer = nil
    end
  end)

  -- function to handle completion of all tasks
  local function check_all_completed()
    jobs_completed = jobs_completed + 1
    if jobs_completed >= total_jobs then
      -- mark as completed to stop updates
      is_completed = true
      -- stop timer
      if update_timer then
        pcall(function()
          update_timer:stop()
          update_timer:close()
        end)
        update_timer = nil
      end
      -- parse output
      local qf_list = parse_output(output_lines, cwd)

      if #qf_list > 0 then
        -- fill quickfix list
        vim.fn.setqflist(qf_list, "r")
        -- open trouble with quickfix
        vim.defer_fn(function()
          local qf_count = #vim.fn.getqflist()
          if qf_count > 0 then
            require("trouble").open("quickfix")
            -- show as error if issues found
            local notify_ok, notify = pcall(require, "notify")
            if notify_ok and notify then
              notify("found " .. qf_count .. " linting issues", "error", { timeout = 5000 })
            else
              vim.notify("found " .. qf_count .. " linting issues", vim.log.levels.error, { timeout = 5000 })
            end
          else
            vim.notify("quickfix list is empty", vim.log.levels.warn, { timeout = 5000 })
          end
        end, 300)
      else
        -- show as success if no errors found
        local notify_ok, notify = pcall(require, "notify")
        if notify_ok and notify then
          notify("no linting errors found", "success", { timeout = 5000 })
        else
          vim.notify("no linting errors found", vim.log.levels.info, { timeout = 5000 })
        end
      end
    end
  end

  -- start yarn lint (eslint)
  local job1 = vim.fn.jobstart({ "yarn", "lint" }, {
    cwd = cwd,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data and #data > 0 then
        for _, line in ipairs(data) do
          if line and line ~= "" then
            table.insert(output_lines, line)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        for _, line in ipairs(data) do
          if line and line ~= "" then
            table.insert(output_lines, line)
          end
        end
      end
    end,
    on_exit = function(_, exit_code)
      check_all_completed()
    end,
  })

  -- start yarn lint-ts (typescript)
  local job2 = vim.fn.jobstart({ "yarn", "lint-ts" }, {
    cwd = cwd,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data and #data > 0 then
        for _, line in ipairs(data) do
          if line and line ~= "" then
            table.insert(output_lines, line)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        for _, line in ipairs(data) do
          if line and line ~= "" then
            table.insert(output_lines, line)
          end
        end
      end
    end,
    on_exit = function(_, exit_code)
      check_all_completed()
    end,
  })

  if job1 == 0 or job2 == 0 then
    is_completed = true
    if update_timer then
      pcall(function()
        update_timer:stop()
        update_timer:close()
      end)
      update_timer = nil
    end
    vim.notify("Failed to start lint jobs", vim.log.levels.ERROR)
  elseif job1 == -1 or job2 == -1 then
    is_completed = true
    if update_timer then
      pcall(function()
        update_timer:stop()
        update_timer:close()
      end)
      update_timer = nil
    end
    vim.notify("Lint commands not found", vim.log.levels.ERROR)
  end
end

return M
