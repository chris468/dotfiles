## JSON Parsing

Use `jq` instead of `python3` for JSON parsing and pretty-printing. `jq` is auto-allowed by Claude Code and avoids permission prompts; `python3` is an interpreter and can never be allowlisted without granting arbitrary code execution.

Common replacements:
- `curl ... | python3 -m json.tool` → `curl ... | jq .`
- `curl ... | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['key'])"` → `curl ... | jq -r '.key'`
- `cat file.json | python3 -c "import json,sys; ..."` → `jq -r '.field' file.json`
