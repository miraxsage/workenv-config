local M = {}

function M.get_project_root(bufnr)
  bufnr = bufnr or 0

  -- LSP root
  for _, client in pairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    local root = client.config and client.config.root_dir
    if root and root ~= "" then
      return root
    end
  end

  -- git root
  local file_dir = vim.fn.expand("%:p:h")
  if file_dir ~= "" then
    local git_root = vim.fn.systemlist({
      "git",
      "-C",
      file_dir,
      "rev-parse",
      "--show-toplevel",
    })[1]

    if git_root and git_root ~= "" and not git_root:match("^fatal:") then
      return git_root
    end
  end

  -- fallback
  return vim.loop.cwd()
end

-- get absoluge path for current file
function M.get_absolute_path()
  return vim.fn.expand("%:p")
end

-- get path relatively project root
function M.get_project_relative_path(bufnr)
  local file = M.get_absolute_path()
  if file == "" then
    return nil
  end

  local root = M.get_project_root(bufnr)
  root = root:gsub("/+$", "")

  if file:sub(1, #root + 1) == root .. "/" then
    return file:sub(#root + 2)
  end

  return file
end

-- copy to clipboard
function M.copy(text)
  if not text or text == "" then
    return false
  end
  vim.fn.setreg("+", text)
  return true
end

return M
