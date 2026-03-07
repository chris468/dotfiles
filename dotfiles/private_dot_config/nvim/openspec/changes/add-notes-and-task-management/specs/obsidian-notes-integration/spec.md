## ADDED Requirements

### Requirement: Obsidian plugin integration SHALL be available in Neovim
The Neovim configuration SHALL install and configure an Obsidian-compatible plugin through LazyVim plugin specs so note operations are accessible from editor commands and keymaps.

#### Scenario: Plugin loads for a configured vault
- **WHEN** Neovim starts with the notes configuration enabled and a valid vault path configured
- **THEN** Obsidian plugin commands become available without manual plugin setup

### Requirement: Obsidian plugin SHALL lazy-load only for markdown files in a detected vault
The Neovim configuration SHALL lazy-load Obsidian functionality when opening a markdown file whose directory, or any parent directory, contains a `.obsidian` folder.

#### Scenario: Markdown file opened inside vault tree
- **WHEN** a markdown file is opened and a `.obsidian` folder is found in the file directory or an ancestor directory
- **THEN** Obsidian plugin integration is loaded for that editing session

#### Scenario: Markdown file opened outside vault tree
- **WHEN** a markdown file is opened and no `.obsidian` folder is found in the file directory or any ancestor directory
- **THEN** Obsidian plugin integration is not auto-loaded by vault detection

### Requirement: Notes commands SHALL support create and find workflows
The configuration SHALL expose note creation and note search commands that operate on the configured Obsidian vault.

#### Scenario: User creates a new note
- **WHEN** the user triggers the mapped new-note action under `<leader>N`
- **THEN** a new note buffer is created in the configured vault using plugin-supported creation behavior

#### Scenario: User finds an existing note
- **WHEN** the user triggers the mapped find-note action under `<leader>N`
- **THEN** the user is presented with searchable note results from the configured vault and can open a selection

### Requirement: Notes mappings SHALL follow the agreed `<leader>N` binding set
The configuration SHALL expose the following notes mappings:
- `<leader>Nn` for new note
- `<leader>Nf` for find note
- `<leader>Nt` for today daily note
- `<leader>Ny` for yesterday daily note
- `<leader>Nm` for tomorrow daily note
- `<leader>Nr` for recent notes
- `<leader>Nv` for vault picker/switch

#### Scenario: User invokes today note mapping
- **WHEN** the user triggers `<leader>Nt`
- **THEN** Neovim opens or creates the daily note for the current date in the resolved vault

### Requirement: Notes keymaps SHALL avoid conflicts with existing mappings
All notes-related keymaps under `<leader>N` SHALL be checked against existing configured mappings before assignment, and conflicting bindings SHALL be replaced with non-conflicting alternatives.

#### Scenario: Candidate mapping conflicts with existing keymap
- **WHEN** a proposed notes keymap is already used elsewhere in the configuration
- **THEN** implementation selects a different `<leader>N` mapping and preserves the original binding

### Requirement: Note and task entrypoints SHALL prompt for vault selection when vault is unset
The configuration SHALL prompt the user to select a vault path when note-taking or task-management functionality is invoked before a vault has been configured or discovered.

#### Scenario: Note action invoked without configured or detected vault
- **WHEN** the user triggers a notes action and no vault path is configured or discoverable
- **THEN** Neovim prompts the user to select the vault path before continuing the action

### Requirement: Vault prompt SHALL support recent selection and new path entry
When vault selection is required, the prompt SHALL present most recently used vault paths and SHALL allow the user to enter a new vault path.

#### Scenario: User selects a recent vault
- **WHEN** the vault prompt is shown and the user chooses a vault from the recent list
- **THEN** the selected vault path is used for the requested action

#### Scenario: User enters a new vault path
- **WHEN** the vault prompt is shown and the user chooses to enter a new path
- **THEN** the entered vault path is validated and used for the requested action

### Requirement: Vault history SHALL include both detected and user-entered paths
The vault history SHALL be updated whenever a vault path is resolved by auto-detection or provided by user selection/entry.

#### Scenario: Vault is found by `.obsidian` auto-detection
- **WHEN** a vault path is resolved by scanning markdown file parent directories
- **THEN** the vault path is stored/updated in history

#### Scenario: Vault is selected or entered by user
- **WHEN** a user selects a recent vault or enters a new vault path in the prompt
- **THEN** the vault path is stored/updated in history

### Requirement: Vault state SHALL use bounded persisted MRU storage
The configuration SHALL persist current vault and MRU history to a local state file with bounded length and stale-path pruning.

#### Scenario: Vault history exceeds maximum length
- **WHEN** a newly resolved vault would grow history beyond the configured cap
- **THEN** the oldest entry is dropped and the MRU list remains bounded

#### Scenario: Stale vault paths exist in history
- **WHEN** vault history is loaded and contains missing directories
- **THEN** stale entries are pruned before presenting recent choices

### Requirement: Vault prompt SHALL provide explicit failure and cancel feedback
Vault resolution SHALL show explicit messages for invalid paths and canceled prompts, and SHALL not run note/task actions when unresolved.

#### Scenario: User enters an invalid vault path
- **WHEN** the user enters a path that does not exist or lacks `.obsidian`
- **THEN** Neovim shows an error and the requested action is aborted

#### Scenario: User cancels vault selection
- **WHEN** the user cancels selection or path input
- **THEN** Neovim shows a warning and the requested action is aborted
