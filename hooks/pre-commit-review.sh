#!/usr/bin/env bash
# zy-skills review gate — blocks `git commit` (ZCode / Claude Code PreToolUse on the Bash tool)
# in repos that ran /setup-skills, until the /review skill has approved the current uncommitted diff.
#
# stdin  : the PreToolUse hook JSON payload
# exit 0 : allow the tool call
# exit 2 : deny, with the reason on stderr
#
# Approval is recorded by the review skill (skills/zy/review/SKILL.md, step 6):
#   git diff HEAD | git hash-object --stdin > "$(git rev-parse --git-dir)/zy-skills-review-approved"
# The marker is consumed on use and only ever matches one exact diff.

set -u

input=$(cat)

# Only gate real `git commit` invocations — the command string inside tool_input.
# ERE only (no GNU \b): boundaries via [^[:alnum:]_-], and \" inside the JSON string
# value is matched as the pair (\\. | [^"\\]) so quoted commands can't slip past.
printf '%s' "$input" | grep -Eq '"command"[[:space:]]*:[[:space:]]*"([^"\\]|\\.)*([^[:alnum:]_-])?git([^"\\]|\\.)*[^[:alnum:]_-]commit([^[:alnum:]_-]|$)' || exit 0

cd "${ZCODE_PROJECT_DIR:-${CLAUDE_PROJECT_DIR:-.}}" || exit 0

# Repo not opted in (no /setup-skills issue tracker), or not a git repo at all: allow.
[ -f docs/agents/issue-tracker.md ] || exit 0
gitdir=$(git rev-parse --git-dir 2>/dev/null) || exit 0

# Approved hash matches the current uncommitted diff? Consume the approval and allow.
diff_hash=$(git diff HEAD 2>/dev/null | git hash-object --stdin)
approved=$(cat "$gitdir/zy-skills-review-approved" 2>/dev/null)
if [ -n "$approved" ] && [ "$approved" = "$diff_hash" ]; then
  rm -f "$gitdir/zy-skills-review-approved"
  exit 0
fi

cat >&2 <<'EOF'
git commit blocked by the zy-skills review gate.

This repo ran /setup-skills, so agent-made commits need a passing review first:

1. Run the /review skill against the uncommitted changes (fixed point HEAD, diff `git diff HEAD`).
2. If both axes report no hard violations, /review records approval for this exact diff.
3. Retry the same git commit — it goes through.

Any change to the diff after the review invalidates the approval and review must re-run.
To commit without a review, ask the user to run git commit in their own terminal.
EOF
exit 2
