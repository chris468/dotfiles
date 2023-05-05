# Install via [chezmoi](https;//chezmoi.io)

## Linux

### Prerequisites

- python3-pip (for neovim python dependencies)

#### devtools
- unzip (for installing aws-cli)
- python3-venv (for installing azure-cli)

```
sh -c "$(curl -fsLS chris468.github.io/dotfiles/install.sh)"
```

## Windows

```
(Invoke-RestMethod -UseBasicParsing https://chris468.github.io/dotfiles/install.ps1) | pwsh -c -
```


# Back up and remove up previous yadm files

```
curl -fsLS https://chris468.github.io/dotfiles/remove-yadm-files.sh | sh -
```

Moves any files managed by yadm to ~/.local/share/dotfiles.bkp, and renames
the yadm repo folder in the same directory. Requires git to be installed.
