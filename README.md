# Install via [chezmoi](https;//chezmoi.io)

## Prerequisites

- python3-pip (for neovim python dependencies)

### devtools
- unzip (for installing aws-cli)
- python3-venv (for installing azure-cli)

```
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $(mktemp -d /tmp/bootstrap-dotfiles-XXX) init --apply --branch chezmoi chris468
```

