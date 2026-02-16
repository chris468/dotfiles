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

# Configuration

## ~/.config/chezmoi.yaml

```
data:
  profile: # all properties reqired, but there will be a prompt or a default in .chezmoi.yaml.tmpl
    work: <bool> # prompted. switches work vs. home settings

  config: # all properties optional, see .chezmoitemplates/configDefaults for defaults
    font:
      family: <string> # name of the font to use for terminals and code editors.
                       # needs to be a nerd font.
      size: <number>   # size of the font for terminals / code editors.

    ssh_hosts:
      - name: <string>  # required, friendly/short name of the ssh host.
        host: <string>  # optional, defaults to name if unset. actual host name.
        type: <string>  # optional
                        #   wezterm: will be added as a wezterm remote multiplexing domain only, not to ssh config.
                                     otherwise it will be added as a remote ssh domain, and to ssh config.
                        #   trusted: will forward ssh agent.
```

## git

`~/.gitconfig` can be used for local config. dotfiles config is added as an include.
