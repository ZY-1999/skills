#!/usr/bin/env bash
set -euo pipefail

# Link plugin.json-registered skills into ~/.config/opencode/skills for OpenCode.
# Idempotent: safe to re-run; refreshes links and prunes stale entries from this repo.
# On Windows (Git Bash/MSYS), uses directory junctions via one PowerShell pass.
# On Unix, uses ln -sfn.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${OPENCODE_SKILLS_DIR:-$HOME/.config/opencode/skills}"
PLUGIN_JSON="$REPO/.claude-plugin/plugin.json"

if [[ ! -f "$PLUGIN_JSON" ]]; then
  echo "error: missing $PLUGIN_JSON" >&2
  exit 1
fi

is_windows() {
  case "$(uname -s 2>/dev/null || echo unknown)" in
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 1 ;;
  esac
}

win_path() {
  cygpath -w "$1"
}

# If DEST itself is a symlink into this repo, per-skill links would write back into the tree.
if [[ -L "$DEST" ]]; then
  resolved="$(readlink -f "$DEST" 2>/dev/null || readlink "$DEST" 2>/dev/null || true)"
  case "$resolved" in
    "$REPO"|"$REPO"/*)
      echo "error: $DEST is a symlink into this repo ($resolved)." >&2
      echo "Remove it (rm \"$DEST\") and re-run; the script will recreate it as a real dir." >&2
      exit 1
      ;;
  esac
fi

mkdir -p "$DEST"

mapfile -t SKILL_RELS < <(
  if command -v jq >/dev/null 2>&1; then
    jq -r '.skills[]' "$PLUGIN_JSON"
  else
    grep -oE '"\./skills/[^"]+"' "$PLUGIN_JSON" | tr -d '"'
  fi
)

if [[ ${#SKILL_RELS[@]} -eq 0 ]]; then
  echo "error: no skills listed in $PLUGIN_JSON" >&2
  exit 1
fi

link_unix() {
  local linked=0 skipped=0 pruned=0 failed=0
  declare -A WANTED_NAMES=()

  for rel in "${SKILL_RELS[@]}"; do
    rel="${rel#./}"
    local src="$REPO/$rel"
    local name target current want
    name="$(basename "$rel")"
    target="$DEST/$name"

    if [[ ! -f "$src/SKILL.md" ]]; then
      echo "error: missing SKILL.md at $src" >&2
      failed=$((failed + 1))
      continue
    fi

    WANTED_NAMES["$name"]=1
    want="$(cd "$src" && pwd)"

    if [[ -L "$target" ]]; then
      current="$(readlink -f "$target" 2>/dev/null || readlink "$target" 2>/dev/null || true)"
      if [[ "$current" == "$want" ]]; then
        skipped=$((skipped + 1))
        echo "ok $name"
        continue
      fi
      rm -f "$target"
    elif [[ -e "$target" ]]; then
      rm -rf "$target"
    fi

    ln -sfn "$src" "$target"
    linked=$((linked + 1))
    echo "linked $name -> $src"
  done

  shopt -s nullglob
  for entry in "$DEST"/*; do
    local name current
    name="$(basename "$entry")"
    [[ -n "${WANTED_NAMES[$name]+x}" ]] && continue
    [[ -L "$entry" ]] || continue
    current="$(readlink -f "$entry" 2>/dev/null || true)"
    case "$current" in
      "$REPO"/skills|"$REPO"/skills/*) ;;
      *) continue ;;
    esac
    rm -f "$entry"
    pruned=$((pruned + 1))
    echo "pruned stale $name"
  done
  shopt -u nullglob

  echo "done: linked=$linked skipped=$skipped pruned=$pruned failed=$failed dest=$DEST"
  [[ "$failed" -eq 0 ]]
}

link_windows() {
  local list_file ps1_file
  list_file="$(mktemp)"
  ps1_file="$(mktemp).ps1"

  for rel in "${SKILL_RELS[@]}"; do
    rel="${rel#./}"
    local src="$REPO/$rel"
    local name
    name="$(basename "$rel")"
    if [[ ! -f "$src/SKILL.md" ]]; then
      echo "error: missing SKILL.md at $src" >&2
      rm -f "$list_file" "$ps1_file"
      return 1
    fi
    # name|source|dest
    printf '%s|%s|%s\n' "$name" "$(win_path "$src")" "$(win_path "$DEST/$name")" >>"$list_file"
  done

  cat >"$ps1_file" <<'EOF'
$ErrorActionPreference = 'Stop'
$listFile = $env:OPENCODE_LINK_LIST
$repoSkills = $env:OPENCODE_REPO_SKILLS
$destRoot = $env:OPENCODE_DEST

$linked = 0; $skipped = 0; $pruned = 0; $failed = 0
$wanted = New-Object 'System.Collections.Generic.HashSet[string]'

function PathsEqual([string]$a, [string]$b) {
  if ([string]::IsNullOrEmpty($a) -or [string]::IsNullOrEmpty($b)) { return $false }
  return ([IO.Path]::GetFullPath($a).TrimEnd('\') -ieq [IO.Path]::GetFullPath($b).TrimEnd('\'))
}

function Remove-Entry([string]$path) {
  if (-not (Test-Path -LiteralPath $path)) { return }
  $i = Get-Item -LiteralPath $path -Force
  if ($i.LinkType -or ($i.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
    cmd /c ("rmdir `"" + $path + "`"") | Out-Null
  } else {
    Remove-Item -LiteralPath $path -Recurse -Force
  }
}

Get-Content -LiteralPath $listFile | ForEach-Object {
  if ([string]::IsNullOrWhiteSpace($_)) { return }
  $parts = $_.Split('|', 3)
  $name = $parts[0]; $src = $parts[1]; $target = $parts[2]
  [void]$wanted.Add($name)

  if (-not (Test-Path -LiteralPath (Join-Path $src 'SKILL.md'))) {
    Write-Host "error: missing SKILL.md at $src"
    $script:failed++
    return
  }

  if (Test-Path -LiteralPath $target) {
    $i = Get-Item -LiteralPath $target -Force
    if ($i.LinkType -and (PathsEqual ([string]($i.Target -join '')) $src)) {
      Write-Host "ok $name"
      $script:skipped++
      return
    }
    Remove-Entry $target
  }

  try {
    New-Item -ItemType Junction -Path $target -Target $src | Out-Null
    Write-Host "linked $name -> $src"
    $script:linked++
  } catch {
    Write-Host "error: failed to link $name -> $src : $_"
    $script:failed++
  }
}

Get-ChildItem -LiteralPath $destRoot -Force | ForEach-Object {
  if ($wanted.Contains($_.Name)) { return }
  $i = $_
  if (-not ($i.LinkType -or ($i.Attributes -band [IO.FileAttributes]::ReparsePoint))) { return }
  $current = [string]($i.Target -join '')
  $prefix = [IO.Path]::GetFullPath($repoSkills).TrimEnd('\')
  $cur = if ($current) { [IO.Path]::GetFullPath($current).TrimEnd('\') } else { '' }
  if (-not $cur) { return }
  if (-not ($cur -ieq $prefix -or $cur.StartsWith($prefix + '\', [StringComparison]::OrdinalIgnoreCase))) { return }
  Remove-Entry $i.FullName
  Write-Host "pruned stale $($i.Name)"
  $script:pruned++
}

Write-Host "done: linked=$linked skipped=$skipped pruned=$pruned failed=$failed dest=$destRoot"
if ($failed -gt 0) { exit 1 }
EOF

  OPENCODE_LINK_LIST="$(win_path "$list_file")"
  OPENCODE_REPO_SKILLS="$(win_path "$REPO/skills")"
  OPENCODE_DEST="$(win_path "$DEST")"
  export OPENCODE_LINK_LIST OPENCODE_REPO_SKILLS OPENCODE_DEST

  local rc=0
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(win_path "$ps1_file")" || rc=$?
  rm -f "$list_file" "$ps1_file"
  return "$rc"
}

if is_windows; then
  link_windows
else
  link_unix
fi
