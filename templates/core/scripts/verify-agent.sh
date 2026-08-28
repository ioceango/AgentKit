#!/usr/bin/env bash
# agent-kit-core: {{KIT_VERSION}}
# Stack-agnostic docs gate: .agent seven files, pointer purity, FEAT/BUG four-docs.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AGENT_DIR="$ROOT_DIR/.agent"
FEATURES_DIR="$ROOT_DIR/docs/features"
BUGFIX_DIR="$ROOT_DIR/docs/bug-fix"
REQUIRED_AGENT=(README.md architecture.md rules.md constraints.md workflow.md verification.md design.md)
REQUIRED_RULES=(
  00-how-to-read.md
  01-code-standards.md
  02-logging.md
  03-engineering-principles.md
  04-layering-and-patterns.md
  05-iteration.md
  06-automated-testing.md
  07-database.md
  08-git.md
  09-deployment.md
  10-context-and-tokens.md
)
REQUIRED_DOCS=(spec.md plan.md checklist.md test-report.md)
PLACEHOLDER_PATTERNS='TODO|待填写|待补充|FIXME|<占位|XXX-占位'

DOC_ISSUES=()
add_issue() { DOC_ISSUES+=("$1"); }

check_agent_spec() {
  local doc present=0
  if [ ! -d "$AGENT_DIR" ]; then
    add_issue ".agent/ 规约目录缺失（跨工具单一事实源，必须存在）"
    return
  fi
  for doc in "${REQUIRED_AGENT[@]}"; do
    if [ ! -f "$AGENT_DIR/$doc" ]; then
      add_issue "缺少跨工具规约文件：.agent/$doc"
      continue
    fi
    if [ ! -s "$AGENT_DIR/$doc" ]; then
      add_issue "跨工具规约文件为空：.agent/$doc"
      continue
    fi
    present=$((present + 1))
  done
  echo "  跨工具规约(.agent)：$present/${#REQUIRED_AGENT[@]} 份文件就绪"
}

check_generic_rules() {
  local doc present=0
  local rules_dir="$ROOT_DIR/docs/rules"
  if [ ! -d "$rules_dir" ]; then
    add_issue "缺少通用细则目录：docs/rules/"
    return
  fi
  for doc in "${REQUIRED_RULES[@]}"; do
    if [ ! -f "$rules_dir/$doc" ]; then
      add_issue "缺少通用细则：docs/rules/$doc"
      continue
    fi
    if [ ! -s "$rules_dir/$doc" ]; then
      add_issue "通用细则为空：docs/rules/$doc"
      continue
    fi
    present=$((present + 1))
  done
  echo "  通用细则(docs/rules)：$present/${#REQUIRED_RULES[@]} 份文件就绪"
}

collect_pointers() {
  POINTERS=(AGENTS.md CLAUDE.md)
  local f
  if [ -d "$ROOT_DIR/.grok/rules" ]; then
    for f in "$ROOT_DIR/.grok/rules"/00-*-rules.md; do
      [ -f "$f" ] || continue
      POINTERS+=("${f#"$ROOT_DIR"/}")
    done
  fi
  if [ -d "$ROOT_DIR/.trae/rules" ]; then
    for f in "$ROOT_DIR/.trae/rules"/00-*-rules.md; do
      [ -f "$f" ] || continue
      POINTERS+=("${f#"$ROOT_DIR"/}")
    done
  fi
}

check_tool_pointers() {
  local pointer pointer_path ok=0 grok_n=0 trae_n=0
  collect_pointers
  for pointer in "${POINTERS[@]}"; do
    pointer_path="$ROOT_DIR/$pointer"
    case "$pointer" in
      .grok/rules/*) grok_n=$((grok_n + 1)) ;;
      .trae/rules/*) trae_n=$((trae_n + 1)) ;;
    esac
    if [ ! -f "$pointer_path" ]; then
      add_issue "缺少工具入口指针文件：$pointer"
      continue
    fi
    if [ ! -s "$pointer_path" ]; then
      add_issue "工具入口指针文件为空：$pointer"
      continue
    fi
    if ! grep -q '\.agent/' "$pointer_path"; then
      add_issue "工具入口指针未指向 .agent/：$pointer（须包含 .agent/ 必读清单）"
      continue
    fi
    if grep -q '^## 关键红线摘要' "$pointer_path"; then
      add_issue "工具入口指针含红线条款拷贝：$pointer（须为纯路标，条款只写在 .agent/）"
      continue
    fi
    ok=$((ok + 1))
  done
  if [ "$grok_n" -lt 1 ]; then
    add_issue "缺少 Grok 入口指针：.grok/rules/00-<slug>-rules.md"
  fi
  if [ "$trae_n" -lt 1 ]; then
    add_issue "缺少 Trae 入口指针：.trae/rules/00-<slug>-rules.md"
  fi
  echo "  工具入口指针：$ok/${#POINTERS[@]} 份有效并指向 .agent/"
}

check_iteration_dir() {
  local dir="$1" pattern="$2" index_file="$3" index_rel="$4"
  local base doc doc_path
  base="$(basename "$dir")"
  if ! [[ "$base" =~ $pattern ]]; then
    add_issue "目录命名不合规：$base（应匹配 ${pattern}）"
    return
  fi
  for doc in "${REQUIRED_DOCS[@]}"; do
    doc_path="$dir/$doc"
    if [ ! -f "$doc_path" ]; then
      add_issue "缺少文档：$base/$doc"
      continue
    fi
    if [ ! -s "$doc_path" ]; then
      add_issue "文档为空：$base/$doc"
      continue
    fi
    if grep -Eq "$PLACEHOLDER_PATTERNS" "$doc_path"; then
      add_issue "文档仍含未完成占位标记：$base/$doc"
    fi
  done
  if [ -f "$index_file" ] && ! grep -q "$base" "$index_file"; then
    add_issue "未登记到索引 $index_rel：$base"
  fi
}

scan_category() {
  local root="$1" pattern="$2" index_rel="$3" label="$4"
  local index_file="$root/README.md"
  local dir count=0 ids=() id
  if [ ! -d "$root" ]; then
    add_issue "$label 目录不存在：$index_rel 的上级目录缺失"
    return
  fi
  if [ ! -f "$index_file" ]; then
    add_issue "$label 索引文件缺失：$index_rel"
  fi
  shopt -s nullglob
  for dir in "$root"/*/; do
    [ -d "$dir" ] || continue
    count=$((count + 1))
    check_iteration_dir "${dir%/}" "$pattern" "$index_file" "$index_rel"
    id="$(basename "${dir%/}" | cut -d- -f1-2)"
    ids+=("$id")
  done
  shopt -u nullglob
  if [ "${#ids[@]}" -gt 0 ]; then
    local dup
    dup="$(printf '%s\n' "${ids[@]}" | sort | uniq -d)"
    if [ -n "$dup" ]; then
      add_issue "$label 存在重复编号：$(echo "$dup" | tr '\n' ' ')"
    fi
  fi
  echo "  ${label} 发现 ${count} 个编号目录"
}

echo "==== 文档合规 gate（verify-agent.sh）===="
check_agent_spec
check_generic_rules
check_tool_pointers
scan_category "$FEATURES_DIR" '^FEAT-[0-9]{3}-[a-z0-9]+(-[a-z0-9]+)*$' "docs/features/README.md" "需求(FEAT)"
scan_category "$BUGFIX_DIR" '^BUG-[0-9]{3}-[a-z0-9]+(-[a-z0-9]+)*$' "docs/bug-fix/README.md" "缺陷(BUG)"

if [ "${#DOC_ISSUES[@]}" -gt 0 ]; then
  echo "文档合规校验未通过，共 ${#DOC_ISSUES[@]} 项问题："
  printf '  - %s\n' "${DOC_ISSUES[@]}"
  exit 1
fi
echo ".agent 规约齐全、工具指针有效、编号目录命名与四文档齐全性、索引登记全部通过"
echo "✓ 文档合规 gate 通过"
exit 0
