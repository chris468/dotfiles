## ADDED Requirements

### Requirement: Taskwarrior integration SHALL be available in Neovim
The Neovim configuration SHALL install and configure a Taskwarrior-oriented plugin or command integration that enables core task operations from inside Neovim.

#### Scenario: Task integration initializes successfully
- **WHEN** Neovim starts on a system with required task tooling installed
- **THEN** task commands for listing and editing tasks are available from Neovim

### Requirement: Task commands SHALL support list add and update actions
The configuration SHALL provide mapped actions for listing tasks, adding a task, and updating task state so users can manage tasks without leaving Neovim.

#### Scenario: User lists tasks
- **WHEN** the user triggers the mapped task-list action under `<leader>N`
- **THEN** Neovim displays current Taskwarrior tasks in the plugin-provided interface

#### Scenario: User adds a task
- **WHEN** the user triggers the mapped add-task action under `<leader>N` and submits task text
- **THEN** a new task is created in Taskwarrior and appears in subsequent task listings

#### Scenario: User updates task completion state
- **WHEN** the user triggers the mapped task-update action under `<leader>N` for a selected task
- **THEN** the corresponding Taskwarrior task state is updated

### Requirement: Task mappings SHALL coexist with notes mappings under one namespace
Task mappings SHALL share the `<leader>N` namespace with notes mappings and SHALL use the `<leader>Nk` subgroup.

#### Scenario: Task mapping collides with existing namespace binding
- **WHEN** a chosen task mapping overlaps an existing `<leader>N` mapping
- **THEN** implementation assigns an alternate non-conflicting mapping while preserving access to all required task actions

### Requirement: Task mappings SHALL follow the agreed `<leader>Nk` binding set
The configuration SHALL expose the following task mappings:
- `<leader>Nk` for task list/hub
- `<leader>Nka` for add task
- `<leader>Nkt` for today task list
- `<leader>Nku` for task update
- `<leader>Nkd` for mark done
- `<leader>Nkp` for pending tasks
- `<leader>Nkr` for refresh/reload task view
- `<leader>Nkv` for task view/filter toggle

#### Scenario: User invokes today task mapping
- **WHEN** the user triggers `<leader>Nkt`
- **THEN** Neovim displays task items scoped to today in the Taskwarrior integration

### Requirement: Task entrypoints SHALL request vault selection when vault is unset
All task management actions under `<leader>Nk*` SHALL prompt for a vault path when no vault has been configured or auto-detected.

#### Scenario: Task action invoked before vault configuration
- **WHEN** the user triggers a task-management action and no vault path is configured or discoverable
- **THEN** Neovim prompts for vault selection and resumes task action after selection

#### Scenario: Task action uses recent vault choice
- **WHEN** a task-management action triggers vault prompt and the user selects a recent vault entry
- **THEN** the task-management action continues using that selected vault path

### Requirement: Task update mapping SHALL provide an explicit action picker
The `<leader>Nku` mapping SHALL present an action picker for selected pending tasks that includes at least `done`, `start`, `stop`, and `annotate`.

#### Scenario: User updates a task with picker action
- **WHEN** the user triggers `<leader>Nku`, selects a task, and chooses an action from the picker
- **THEN** the selected Taskwarrior action is executed for that task

### Requirement: Task actions SHALL present clear failure and empty-state messages
Task actions SHALL avoid silent failures by showing explicit messages for missing CLI dependencies, canceled prompts, invalid vault paths, and empty results.

#### Scenario: Taskwarrior CLI is missing
- **WHEN** a task mapping is invoked and `task` is not available in `PATH`
- **THEN** Neovim shows an error describing the missing dependency and no task command runs

#### Scenario: No pending tasks are available for selection
- **WHEN** a task update or completion action is invoked and no pending tasks are available
- **THEN** Neovim shows an informational message and does not fail

### Requirement: Taskwarrior mappings SHALL remain distinct from Overseer mappings
Taskwarrior mappings under `<leader>Nk*` SHALL remain conceptually and operationally separate from Overseer run/build mappings under `<leader>o*`.

#### Scenario: User accesses build tasks
- **WHEN** the user invokes existing Overseer mappings
- **THEN** Overseer behavior remains unchanged and separate from Taskwarrior personal task actions
