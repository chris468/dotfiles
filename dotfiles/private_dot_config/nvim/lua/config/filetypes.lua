vim.filetype.add({
  extension = {
    -- lsp is only registered for the terraform and terraform-vars filetypes,
    -- but *.tf files are detected as tf.
    tf = "terraform",
  },
  pattern = {
    -- nothing seems to register the docker-compose extensions
    ["docker%-compose%.ya?ml"] = "yaml.docker-compose",
    ["docker%-compose%..*%.ya?ml"] = "yaml.docker-compose",
  },
})
