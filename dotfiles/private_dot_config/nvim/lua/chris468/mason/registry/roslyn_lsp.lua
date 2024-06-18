local version = "4.8.0-2.23428.2"
local package = "Microsoft.Codeanalysis.LanguageServer"
local repo =
  "https://pkgs.dev.azure.com/azure-public/3ccf6661-f8ce-4e8a-bb2e-eff943ddd3c7/_packaging/36a629e1-6c5b-4bcd-aa2e-6018802d6b99/nuget/v3/flat2/"
local uri = repo .. string.lower(package) .. "/{{version}}" .. "/" .. string.lower(package) .. ".{{version}}.nupkg"
local download_filename = package .. ".nupkg.zip"

local arch_mapping = {
  x86_64 = "x64",
}

local os_mapping = {
  darwin = "osx",
}

local uname = vim.uv.os_uname()
local arch = string.lower(uname.machine)
arch = arch_mapping[arch] or arch
local os = string.lower(uname.sysname)
os = os_mapping[os] or os

local rid = os .. "-" .. arch

local spec = {
  schema = "registry+v1",
  name = "chris468_roslyn_lsp",
  description = "Roslyn LSP",
  desc = "Roslyn LSP",
  homepage = "http://www.example.com",
  licenses = {},
  categories = { "LSP" },
  languages = { "C#" },
  source = {
    id = "pkg:generic/chris468_roslyn_lsp@" .. version,
    download = {
      files = {
        [download_filename] = uri,
      },
    },
  },
  bin = {
    roslyn_lsp = "dotnet:content/LanguageServer/" .. rid .. "/Microsoft.CodeAnalysis.LanguageServer.dll",
  },
}

return require("mason-core.package").new(spec)
