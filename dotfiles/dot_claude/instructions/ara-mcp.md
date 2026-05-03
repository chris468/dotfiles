## ARA MCP Tools

ARA Records Ansible. It captures every play, task, result, and host from `ansible-playbook` runs
and stores them in a database accessible via a REST API. The `ara-mcp` MCP server provides
read-only access to that recorded data.

**When investigating a failing playbook or molecule test, use ARA MCP tools rather than pasting
raw `ansible-playbook` output.** Raw output often costs 60,000+ tokens; the MCP tools return the
same information in ~2,000 tokens because you can ask for exactly what you need.

### Data Model

```
Playbook (one ansible-playbook invocation)
├── Tasks    — each task definition; has action (module), name, file path + line
├── Hosts    — each targeted host; has aggregate ok/changed/failed/skipped counts + facts
├── Results  — one per task × host; has status, stdout/stderr, error messages
└── Files    — playbooks, roles, templates recorded during the run
```

### Investigation Workflow

**Start with wrapper tools — they aggregate multiple API calls into one report:**

- `troubleshoot_playbook(id=<id>)` — first call when a playbook failed; aggregates all failures,
  error messages, source code context, and host facts
- `troubleshoot_host(id=<id>)` — when a specific host is having problems across runs
- `analyze_performance(id=<id>)` — when a playbook is unexpectedly slow

**Then drill down with foundation tools as needed:**

- `list_playbooks(path=<path>)` — find recent runs of the same playbook
- `list_results(status=failed, task=<id>)` — find which hosts failed a specific task
- `get_result(id=<id>)` — full stdout/stderr of a specific failure
- `get_file(id=<id>, line=<n>)` — source code context around a failure

### Key Caveats

- **IDs are per-run.** A host ID represents that host in a specific execution; the same physical
  host has different IDs across different runs.
- **Filter aggressively.** Use `status=failed`, `task=<id>`, or `host=<id>` — never call
  `list_results` on a large playbook without filters.
- **Don't guess IDs.** Always use IDs returned by list/get tool responses.
- **`ignore_errors` tasks** are excluded from `troubleshoot_playbook` by default; pass
  `include_ignored=true` if the playbook shows "completed" but the user reports errors.
