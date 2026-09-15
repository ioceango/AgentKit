# agent-kit

跨项目 **vibe coding 骨架**。定位：

- 空项目初始化，或已有 vibe 骨架时补齐规范。
- 编码助手按 [`LLM-PROMPT.md`](LLM-PROMPT.md) 执行本目录的 `install-agent-kit.sh`。
- **与业务无关的工业化流程**沉淀在 core 的 `docs/rules/00`–`10`；换项目仍遵守。
- **唯一按项目改的**是 overlay：产品红线、模块地图、视觉、本栈验证命令。

本目录是通用能力沉淀，不接入来源应用树，不走来源仓的 FEAT 管理。

## 分层

| 层 | 换项目还成立 | 内容 |
|----|----------------|------|
| core | 是 | `.agents` 执行口、确认门、十条细则、门禁、提示词 |
| overlay | 否 | `constraints` / `architecture` / `design` |
| adapters | 只因工具入口 | `AGENTS.md`、`CLAUDE.md`、`.grok/rules`、`.trae/rules`（纯路标） |

## 通用细则（01–10）

装进目标仓 `docs/rules/`：代码规范、日志、软件工程原则、分层与设计模式、需求与 Bug 迭代、自动化测试、数据库、Git、部署、上下文与 tokens。指针里只留清单，不抄细则正文。

## 最小安装

```bash
bash show/agent-kit/install-agent-kit.sh --root /path/to/app --name "My Product" --slug my-product
bash /path/to/app/scripts/verify-agent.sh
```

安装器会打印 `mode=empty` 或 `mode=existing`。已有 `.agents/constraints.md` 时不覆盖 overlay。升级通用细则用 `--force-core`。

| 参数 | 含义 |
|------|------|
| `--root` | 目标根目录，默认 `.` |
| `--name` | 产品显示名 |
| `--slug` | 小写短横线，指针文件 `00-<slug>-rules.md` |
| `--force-core` | 覆盖 core（含 `docs/rules/00–10`）与仍为路标的 adapters |
| `--with-mcp` | 写 `.mcp.json`；**必须**同时给 `--mcp-cli` |
| `--mcp-cli` | Playwright MCP cli 相对目标根的路径 |
| `--with-ci` | 写 `.github/workflows/agent-docs.yml` |
| `--with-review-skill` | 拷通用 code-review skill |

## 装完必做（overlay）

1. 填写 `.agents/constraints.md`、`architecture.md`、`design.md`。
2. 在 `.agents/verification.md` §1.1 补本栈 lint / test / e2e。
3. 第一个需求走确认门：`docs/features/FEAT-001-<slug>/`。
