# dotfiles

## Prerequisites

Requires [Python 3.9](https://www.python.org/downloads/) or newer. On Windows, it will be lauched via `py -3.9`, on Linux via `python3.9`.

## Linux

### Install

```
curl -L https://raw.githubusercontent.com/chris468/dotfiles/main/get.sh | bash
```

### Upgrade

If using fish:

```
update_dotfiles
```

otherwise:

```
~/.config/dotfiles/update.sh
```

## Windows

### Setup

The install / update scripts create create hard links, but users do not have permission to create
them by default. Either run the install script as admin, or give the user permission to create hard
links. Launch `Start -> Local Security Policy`, browse to `Security Settings -> Local Policies -> User
Rights Assignment`, open `Create symbolic links`, and add the `Users` group or individual users.

### Install

```
Invoke-WebRequest  https://raw.githubusercontent.com/chris468/dotfiles/main/get.ps1 | Invoke-Expression
```

### Upgrade

```
Update-Dotfiles
```

or

```
~\.config\dotfiles\update.ps1
```
