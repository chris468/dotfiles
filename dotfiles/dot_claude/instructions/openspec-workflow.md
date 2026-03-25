## Git Workflow

The *how* to run lint and tests is defined in the project's own CLAUDE.md. The rules below
govern commit discipline and workflow structure regardless of which commands are used.

**Branch setup (at implementation start)**

- The change proposal and artifacts (tasks.md, design docs, etc.) are committed to `main` before implementation begins
- Create an implementation branch from `main`, named after the change:
  `git checkout -b impl/<change-name> main`
- Do not merge the implementation branch — leave that for manual review
- Only begin a change if all its prerequisites are already merged to `main`;
  if a dependency is in an unmerged branch, that change is blocked until it is merged

**Per-task commits**

- Top-level tasks in tasks.md are sized to represent a single logical commit — keep this in mind when authoring tasks.md during planning
- Every commit must leave the repo in a fully functional, releasable state — never commit partial work that breaks or disables existing functionality. Lint and tests passing is necessary but not sufficient.
- The target is one commit per top-level task (section), including all its subtasks; if implementation reveals a task is larger than planned, it may be split into multiple commits provided each commit meets the above requirement
- Check off all completed subtasks in tasks.md, then include tasks.md in the commit alongside the implementation
- After each commit, use judgment about whether to continue to the next section or pause for review:
  - **Continue** when the commit was low-risk: mechanical changes, renames, or tasks with no behavior change and no surprises during implementation
  - **Pause** when the commit introduced new behavior, architectural decisions, or when anything unexpected arose — wait for review before building the next section on top of it
  - When authoring tasks.md and a section is clearly significant upfront, include an explicit note in that section's description that review is required before the next section begins
  - If rework on a prior commit is needed: `git reset --soft HEAD~N` undoes N commits while preserving staged changes for recommitting; `git rebase -i` requires interactive input and should be run manually if needed

