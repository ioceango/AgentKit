<!-- agent-kit-core: {{KIT_VERSION}} -->
# `.agents/skills/` — 仓库技能包权威目录

本目录是 **{{PROJECT_NAME}}** 的 skill 正文唯一落点。不在 `.grok/skills/`、`.claude/skills/`、`.cursor/skills/` 再各放一份。

## 约定

- 每个技能一个子目录：`.agents/skills/<name>/SKILL.md`（YAML frontmatter + markdown 步骤）。
- 本目录只放项目相关、可复用的任务包；通用规约仍写在 `.agents/*.md`。

## 已登记

| 名称 | 何时用 |
|------|--------|
| （安装 `--with-review-skill` 后会出现 code-review） | 按本项目 `.agents/architecture.md` 分视角审查；结果写入该迭代 `review-report/` |

## 各工具如何读到这里

| 工具 | 方式 |
|------|------|
| Grok Build / Grok CLI | 项目 `.grok/config.toml` 的 `[skills] paths = [".agents/skills"]` |
| Claude / Cursor 等 | 按其官方 skills 发现机制把本目录加入额外路径，或做软链。禁止复制正文。 |
