## Why

This Neovim setup currently lacks a first-class workflow for structured notes and terminal-native task tracking. Adding integrated Obsidian and Taskwarrior support now will unify personal knowledge and actionable tasks behind consistent, discoverable keymaps.

## What Changes

- Add an Obsidian plugin integration for creating, searching, and navigating notes from within Neovim.
- Add a Taskwarrior-oriented plugin integration to view and manage tasks without leaving Neovim.
- Load Obsidian integration only when opening markdown files inside an Obsidian vault, detected by finding a `.obsidian` directory in the file's directory or any parent directory.
- Prompt the user to pick a vault path when note or task actions are invoked before a vault has been configured.
- Keep a most-recently-used list of vault paths and, during prompting, allow choosing a recent vault or entering a new path.
- Add vault paths to history whether they were auto-detected or user-entered.
- Introduce a cohesive keymap namespace under `<leader>N` for notes and task management actions.
- Require keymap conflict checks so new mappings do not override existing bindings.
- Document new commands and keymaps for daily usage.

## Capabilities

### New Capabilities
- `obsidian-notes-integration`: Integrates Obsidian note-taking workflows in Neovim, including note creation, lookup, and navigation.
- `taskwarrior-task-management`: Integrates Taskwarrior task workflows in Neovim, including listing, creating, and updating tasks via keymaps.

### Modified Capabilities
- None.

## Impact

- Affected code: Neovim plugin declarations, plugin configuration modules, and keymap definitions in this dotfiles repo.
- Dependencies: Adds/uses Obsidian and Taskwarrior Neovim plugins; requires local `taskwarrior` CLI for full task actions.
- User workflow: Introduces a new `<leader>N` mnemonic mapping group for notes/tasks.
