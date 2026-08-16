#!/usr/bin/env bash
# benjamin-plus SessionStart hook: emits the ruleset as session context.
# Register in Claude Code settings.json:
#   "hooks": {"SessionStart": [{"matcher": "startup|resume|clear|compact",
#     "hooks": [{"type": "command", "command": "bash /path/to/hooks/sessionstart.sh"}]}]}
# The matcher re-injects after /clear and compaction — the two events that
# silently wipe injected context.
cat "$(dirname "$0")/../injected-instruction.md"
