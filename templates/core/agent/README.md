<!-- agent-kit-core: {{KIT_VERSION}} -->
# .agent/ — 跨 AI 编码工具统一规约（单一事实源）

> 本目录是本仓库对**所有外部 AI 编码工具**生效的强制规约集合。
> Grok build / Grok CLI、DeepSeek harness (dsh)、Codex、Claude Code、Cursor、Trae 等在本仓库工作时，
> 必须以本目录内容为唯一执行依据。
> **任何冲突，一律以 `.agent/` 为准。**

产品名：**{{PROJECT_NAME}}**。产品红线写在 `constraints.md`，本文件只说明怎么读规约、指针和 skills。

## 1. 阅读顺序（不可跳过）

| 顺序 | 文件 | 内容 |
|------|------|------|
| 1 | `.agent/README.md`（本文件） | 单一事实源声明、工具入口映射 |
| 2 | `.agent/workflow.md` | 迭代流程与用户确认门（何时才允许改代码） |
| 3 | `.agent/constraints.md` | 能力边界与红线（不能做什么） |
| 4 | `.agent/rules.md` | 工程规范硬约束（怎么写） |
| 5 | `.agent/architecture.md` | 系统架构与模块职责（改哪里） |
| 6 | `.agent/verification.md` | 验证命令、顺序与完成定义（何时算做完） |
| 7 | `.agent/design.md` | 视觉设计（非安全红线） |

七份读完才允许动手。视觉实现以 `design.md` 为准。
与业务无关的工业化细则在 `docs/rules/00`–`10`（代码、日志、工程原则、分层与模式、迭代、测试、数据库、Git、部署、上下文/tokens）。**按需打开，禁止整组贴进指针。** 产品与技术栈只写 overlay：`constraints.md` / `architecture.md` / `design.md`。

## 2. 单一事实源声明

- 规约正文**只写在 `.agent/`**。
- 根 `AGENTS.md`、`CLAUDE.md`、`.grok/rules/*.md`、`.trae/rules/*.md` 一律为**纯路标**：只保留「这是谁的入口 + 指向 `.agent/` 的必读清单 + 验证命令」。**禁止**在指针里复制红线条目或其他条款。
- **禁止**在指针文件中新增、改写、扩写任何规则。发现指针与 `.agent/` 不一致时，以 `.agent/` 为准并修正指针（通常是删掉指针里多出来的条款）。
- 规约变更只允许改 `.agent/` 下对应文件。
- `docs/rules/` 是给人读的细则展开；与 `.agent/` 冲突时**改细则、不改执行口径**。

## 3. 工具入口映射

| 工具 | 官方入口机制 | 本仓库生效路径 |
|------|-------------|---------------|
| Grok build / Grok CLI | 根 `AGENTS.md` 与 `<repo>/.grok/rules/*.md` | 两处指针 → `.agent/`。不能删除 `.grok/rules/` 还指望 Grok 自己找到 `.agent/` |
| Codex | 根 `AGENTS.md`（注意指令体积上限） | 指针 → `.agent/` |
| Claude Code | `CLAUDE.md` | 指针 → `.agent/` |
| DeepSeek harness (dsh) | 无已核实的专有仓库指令格式 | 根 `AGENTS.md` → `.agent/`。不臆造 `.dsh/` |
| Cursor / Jules / Copilot 等 | 通用 `AGENTS.md` | 指针 → `.agent/` |
| Trae | `AGENTS.md` 与 `.trae/rules/` | 两处指针 → `.agent/` |

新增工具：查官方入口文件名 → 加一份最短指针 → 列入 `scripts/verify-agent.sh` 的指针检查。

## 4. Skills

- **权威目录**：`.agent/skills/`。每个技能一个子目录：`.agent/skills/<name>/SKILL.md`。
- **不要**在 `.grok/skills/`、`.claude/skills/`、`.cursor/skills/` 再放一份正文。
- Grok 默认不扫描 `.agent/skills/`。项目 `.grok/config.toml` 须有 `[skills] paths = [".agent/skills"]`。

## 5. MCP

- 协议通用；配置文件格式不通用。
- 通用清单：仓库根 `.mcp.json`（若已安装）。
- Grok 专有：`.grok/config.toml` 的 `[mcp_servers.*]`。改 command/args 时先改 `.mcp.json` 再同步 TOML。密钥只用环境变量。

## 6. 自检

```bash
bash scripts/verify-agent.sh
```
