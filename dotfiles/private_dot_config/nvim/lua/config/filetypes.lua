vim.filetype.add({
  extension = {
    -- lsp is only registered for the terraform and terraform-vars filetypes,
    -- but *.tf files are detected as tf.
    tf = "terraform",
    md = function(path)
      local obsidian_parents = vim.fs.find(".obsidian", { upward = true, path = path })
      if obsidian_parents and obsidian_parents[1] then
        return "markdown.obsidian"
      end

      return "markdown"
    end,
  },
  pattern = {
    -- nothing seems to register the docker-compose extensions
    ["docker%-compose%.ya?ml"] = "yaml.docker-compose",
    ["docker%-compose%..*%.ya?ml"] = "yaml.docker-compose",
  },
})

vim.filetype.add({})
