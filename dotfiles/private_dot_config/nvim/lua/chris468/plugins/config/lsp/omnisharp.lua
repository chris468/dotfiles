return {
  cmd = { "omnisharp" },
  settings = {
    FormattingOptions = {
      OrganizeImports = true,
    },
    RoslynExtensionsOptions = {
      EnableAnalyzersSupport = true,
      EnableImportCompletion = true,
    },
  },
}
