local M = {
  names = {
    tool1 = {
      name = "tool1",
    },
    tool2 = {
      name = "tool2",
    },
    tool3 = {
      name = "tool3",
    },
    lsp = {
      name = "lsp",
    },
    lsp_with_name = {
      name = "lsp_with_name",
      tool_name = "lsp_name",
    },
    dap = {
      name = "dap_pkg"
    }
  },
}

function M.create(name, opts)
  return vim.tbl_deep_extend("keep", opts or {}, {
    name = name,
    description = ("This is a fake %s package."):format(name),
    homepage = "https://example.com",
    licenses = { "MIT" },
    languages = { "DummyLang" },
    categories = { "LSP" },
    source = {
      id = ("pkg:mason/%s@1.0.0"):format(name),
      ---@async
      ---@param ctx InstallContext
      install = function(ctx) end,
    },
  })
end

return M
