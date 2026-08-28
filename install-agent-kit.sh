#!/usr/bin/env bash
# Install the vibe-coding agent kit into a target project.
# Overlay files are never overwritten. Core/adapters follow --force-core.
set -euo pipefail

KIT_HOME="$(cd "$(dirname "$0")" && pwd)"
KIT_VERSION="$(tr -d ' \n' < "$KIT_HOME/VERSION")"
ROOT="."
NAME=""
SLUG=""
FORCE_CORE=0
WITH_MCP=0
MCP_CLI=""
WITH_CI=0
WITH_REVIEW=0

usage() {
  cat <<'EOF'
Usage: install-agent-kit.sh --root <dir> --name <product> --slug <slug> [options]
  --root PATH           Target project root (default: .)
  --name TEXT           Product display name (required)
  --slug SLUG           Lowercase hyphen slug (required), used in 00-<slug>-rules.md
  --force-core          Overwrite core files and pointer adapters
  --with-mcp            Write .mcp.json and Grok MCP block (requires --mcp-cli)
  --mcp-cli RELPATH     Playwright MCP cli path relative to --root
  --with-ci             Write .github/workflows/agent-docs.yml
  --with-review-skill   Copy generic code-review skill under .agent/skills/
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --root) ROOT="$2"; shift 2 ;;
    --name) NAME="$2"; shift 2 ;;
    --slug) SLUG="$2"; shift 2 ;;
    --force-core) FORCE_CORE=1; shift ;;
    --with-mcp) WITH_MCP=1; shift ;;
    --mcp-cli) MCP_CLI="$2"; shift 2 ;;
    --with-ci) WITH_CI=1; shift ;;
    --with-review-skill) WITH_REVIEW=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

if [ -z "$NAME" ] || [ -z "$SLUG" ]; then
  echo "--name and --slug are required" >&2
  usage
  exit 2
fi
if ! [[ "$SLUG" =~ ^[a-z][a-z0-9-]*$ ]]; then
  echo "--slug must match ^[a-z][a-z0-9-]*$ (got: $SLUG)" >&2
  exit 2
fi
if [ "$WITH_MCP" -eq 1 ] && [ -z "$MCP_CLI" ]; then
  echo "--with-mcp requires --mcp-cli (path relative to --root)" >&2
  exit 2
fi
if [ ! -d "$ROOT" ]; then
  echo "--root is not a directory: $ROOT" >&2
  exit 2
fi
ROOT="$(cd "$ROOT" && pwd)"

export KIT_PROJECT_NAME="$NAME"
export KIT_PROJECT_SLUG="$SLUG"
export KIT_VERSION
export KIT_MCP_CLI="$MCP_CLI"

subst() {
  python3 -c '
import os, sys
src, dest = sys.argv[1], sys.argv[2]
text = open(src, encoding="utf-8").read()
text = text.replace("{{PROJECT_NAME}}", os.environ["KIT_PROJECT_NAME"])
text = text.replace("{{PROJECT_SLUG}}", os.environ["KIT_PROJECT_SLUG"])
text = text.replace("{{KIT_VERSION}}", os.environ["KIT_VERSION"])
text = text.replace("{{MCP_CLI}}", os.environ.get("KIT_MCP_CLI", ""))
parent = os.path.dirname(dest)
if parent:
    os.makedirs(parent, exist_ok=True)
open(dest, "w", encoding="utf-8").write(text)
' "$1" "$2"
}

should_write_core() {
  local dest="$1"
  if [ ! -f "$dest" ]; then
    return 0
  fi
  if [ "$FORCE_CORE" -eq 1 ]; then
    return 0
  fi
  return 1
}

install_core_tree() {
  local src="$KIT_HOME/templates/core"
  local f rel dest
  while IFS= read -r f; do
    rel="${f#"$src"/}"
    case "$rel" in
      agent/*) dest="$ROOT/.agent/${rel#agent/}" ;;
      scripts/*) dest="$ROOT/scripts/${rel#scripts/}" ;;
      docs/*) dest="$ROOT/docs/${rel#docs/}" ;;
      *) dest="$ROOT/$rel" ;;
    esac
    if should_write_core "$dest"; then
      subst "$f" "$dest"
      if [ -x "$f" ] || [[ "$dest" == *.sh ]]; then
        chmod +x "$dest"
      fi
      echo "core  write  ${dest#"$ROOT"/}"
    else
      echo "core  skip   ${dest#"$ROOT"/}"
    fi
  done < <(find "$src" -type f | sort)
}

install_overlay_tree() {
  local src="$KIT_HOME/templates/overlay"
  local f rel dest
  while IFS= read -r f; do
    rel="${f#"$src"/}"
    case "$rel" in
      agent/*) dest="$ROOT/.agent/${rel#agent/}" ;;
      docs/*) dest="$ROOT/docs/${rel#docs/}" ;;
      *) dest="$ROOT/$rel" ;;
    esac
    if [ -f "$dest" ]; then
      echo "overlay skip  ${dest#"$ROOT"/}"
      continue
    fi
    subst "$f" "$dest"
    echo "overlay write ${dest#"$ROOT"/}"
  done < <(find "$src" -type f | sort)
}

assert_pointer_or_missing() {
  local dest="$1"
  [ ! -f "$dest" ] && return 0
  if ! grep -q '\.agent/' "$dest"; then
    echo "refusing to overwrite adapter that does not point at .agent/: ${dest#"$ROOT"/}" >&2
    exit 1
  fi
  if grep -q '^## 关键红线摘要' "$dest"; then
    echo "refusing to overwrite adapter that contains copied red-lines: ${dest#"$ROOT"/}" >&2
    exit 1
  fi
}

write_adapter() {
  local src="$1" dest="$2"
  assert_pointer_or_missing "$dest"
  if [ -f "$dest" ] && [ "$FORCE_CORE" -eq 0 ]; then
    # First install: dest missing. Re-run: keep pointers unless --force-core.
    # Still rewrite when missing only; existing valid pointers: skip (idempotent).
    echo "adapter skip  ${dest#"$ROOT"/}"
    return
  fi
  subst "$src" "$dest"
  echo "adapter write ${dest#"$ROOT"/}"
}

install_adapters() {
  write_adapter "$KIT_HOME/templates/adapters/AGENTS.md" "$ROOT/AGENTS.md"
  write_adapter "$KIT_HOME/templates/adapters/CLAUDE.md" "$ROOT/CLAUDE.md"
  write_adapter "$KIT_HOME/templates/adapters/grok-rules.md" "$ROOT/.grok/rules/00-${SLUG}-rules.md"
  write_adapter "$KIT_HOME/templates/adapters/trae-rules.md" "$ROOT/.trae/rules/00-${SLUG}-rules.md"
}

install_grok_skills_toml() {
  local dest="$ROOT/.grok/config.toml"
  if [ "$WITH_MCP" -eq 1 ]; then
    return
  fi
  if [ -f "$dest" ] && [ "$FORCE_CORE" -eq 0 ]; then
    echo "optional skip  .grok/config.toml"
    return
  fi
  subst "$KIT_HOME/templates/optional/grok.skills.toml" "$dest"
  echo "optional write .grok/config.toml"
}

install_optional() {
  if [ "$WITH_MCP" -eq 1 ]; then
    subst "$KIT_HOME/templates/optional/mcp.json" "$ROOT/.mcp.json"
    echo "optional write .mcp.json"
    subst "$KIT_HOME/templates/optional/grok.config.toml" "$ROOT/.grok/config.toml"
    echo "optional write .grok/config.toml (mcp)"
  fi
  if [ "$WITH_CI" -eq 1 ]; then
    local ci="$ROOT/.github/workflows/agent-docs.yml"
    if [ -f "$ci" ] && [ "$FORCE_CORE" -eq 0 ]; then
      echo "optional skip  .github/workflows/agent-docs.yml"
    else
      subst "$KIT_HOME/templates/optional/agent-docs.yml" "$ci"
      echo "optional write .github/workflows/agent-docs.yml"
    fi
  fi
  if [ "$WITH_REVIEW" -eq 1 ]; then
    local f dest rel
    local src="$KIT_HOME/templates/optional/skills/code-review"
    while IFS= read -r f; do
      rel="${f#"$src"/}"
      dest="$ROOT/.agent/skills/code-review/$rel"
      if [ -f "$dest" ] && [ "$FORCE_CORE" -eq 0 ]; then
        echo "optional skip  .agent/skills/code-review/$rel"
        continue
      fi
      subst "$f" "$dest"
      echo "optional write .agent/skills/code-review/$rel"
    done < <(find "$src" -type f | sort)
  fi
}

if [ -f "$ROOT/.agent/constraints.md" ] || [ -f "$ROOT/AGENTS.md" ]; then
  MODE=existing
else
  MODE=empty
fi
echo "agent-kit $KIT_VERSION -> $ROOT  name=$NAME slug=$SLUG  mode=$MODE"
install_core_tree
install_overlay_tree
install_adapters
install_grok_skills_toml
install_optional

echo "running $ROOT/scripts/verify-agent.sh"
bash "$ROOT/scripts/verify-agent.sh"
echo "install ok"
