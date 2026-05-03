# ARA MCP Investigation Reference

ARA Records Ansible. The `ara-mcp` MCP server gives read-only access to recorded playbook data.
This command loads the full investigation reference into context.

## Data Model

```
Playbook (one ansible-playbook invocation)
├── Tasks    — each task definition; has action (module), name, file path + line number
├── Hosts    — each targeted host; aggregate ok/changed/failed/skipped counts + Ansible facts
├── Results  — one per task × host; has status, stdout/stderr, return codes, error messages
└── Files    — playbooks, roles, templates recorded during the run
```

Every object has a numeric ID. Tools accept either a numeric ID or a full ARA web UI URL.

## Investigation Workflow

### Step 1: Start broad with wrapper tools

These make multiple API calls internally and return a consolidated report. Always try these first.

**`troubleshoot_playbook(id=<id>)`** — use when a playbook has failed. Returns all failures,
their error messages, source code context, and relevant host facts in one call. This is almost
always the right starting point.

**`troubleshoot_host(id=<id>)`** — use when a specific host is having problems across multiple
runs. Returns a host-centric view of failures.

**`analyze_performance(id=<id>)`** — use when a playbook is unexpectedly slow. Identifies
the slowest tasks, breaks down time by Ansible module, and compares across runs.

### Step 2: Drill down with foundation tools

After reviewing wrapper output, use these for specific follow-up:

- `get_playbook(id=<id>)` — full playbook detail: status, duration, Ansible version, controller
- `get_task(id=<id>)` — task definition and source file location
- `get_result(id=<id>)` — complete stdout/stderr of a specific result
- `get_host(id=<id>)` — OS facts, Python version, kernel; useful for environment-specific failures
- `get_file(id=<id>, line=<n>)` — source code context around a specific line
- `list_playbooks(path=<path>, order="-started", limit=10)` — recent runs of the same playbook
- `list_results(status=failed, task=<id>)` — which hosts failed a specific task
- `list_tasks(playbook=<id>)` — all tasks in a run

## Common Investigation Patterns

### "Why did this playbook fail?"
```
troubleshoot_playbook(id=<playbook_id>)
```
Read the failure list, error messages, and code context. Follow up with `get_result` for more
detail on a specific failure.

### "Is this host broken?"
```
troubleshoot_host(id=<host_id>)
```
Check if failures are consistent (same task every time) or intermittent. Look at host facts —
different OS version? Missing Python?

### "This playbook is too slow"
```
analyze_performance(id=<playbook_id>)
```
Common culprits: slow fact gathering (consider `gather_subset: min`), sequential package
installs (batch them), low fork count (raise `forks` in `ansible.cfg`).

### "Did this work before?"
```
list_playbooks(path=<playbook_path>, order="-started", limit=10)
```
Find recent runs of the same playbook. Compare statuses and durations. If a previously-passing
playbook now fails, focus on what changed between the last success and first failure.

### "Did it fail on all hosts or just one?"
```
list_results(status=failed, task=<task_id>)
```
Filter by task ID to see which hosts failed it. Then `get_host` on a failing host to check
for environment differences vs. a passing host.

## Things to Keep in Mind

- **IDs are per-run.** A host ID in ARA is not a global host identifier — the same physical
  host has different ARA host IDs across different playbook executions.

- **Filter aggressively.** Never call `list_results` with no filters on a large playbook.
  Filter by `status=failed`, `task=<id>`, or `host=<id>` first.

- **Don't guess IDs.** IDs are returned by list and get tools. Always use IDs from previous
  tool responses rather than assuming sequential numbering.

- **`ignore_errors` tasks** are excluded from `troubleshoot_playbook` by default. If a playbook
  shows as "completed" but the user reports errors, try `include_ignored=true`.

- **Facts may not be available.** If a playbook uses `gather_facts: false`, host facts will be
  empty. This is normal.

- **ARA data is a snapshot.** ARA records what happened during a run. The current state of a
  host may have changed since then — don't confuse recorded state with live system state.

- **Pagination.** List tools return paginated results. Use `limit` and filter aggressively
  rather than trying to fetch everything at once.

- **Duration strings are `HH:MM:SS`.** The `duration` field is a string like `0:01:23.456789`.
  Wrapper tools parse these for you; foundation tools return the raw string.

- **The controller** is the machine that ran Ansible, not the target host.

## What Not to Do

- Don't call `list_results` on a large playbook without filters.
- Don't guess at IDs — use what the tools return.
- Don't paste raw `ansible-playbook` output when ARA has the data.
- Don't confuse recorded ARA data with the current live state of hosts.
