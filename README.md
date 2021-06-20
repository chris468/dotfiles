# dotfiles

## Linux

### Install

```
curl -L https://raw.githubusercontent.com/chris468/dotfiles/main/install.sh | bash
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
Invoke-WebRequest  https://raw.githubusercontent.com/chris468/dotfiles/main/install.ps1 | Invoke-Expression
```

### Upgrade

```
Update-Dotfiles
```

or

```
~\.config\dotfiles\update.ps1
```
