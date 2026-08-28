<!-- agent-kit-core: {{KIT_VERSION}} -->
# .agent/rules.md — 工程规范硬约束（执行口）

> 产品边界在 `constraints.md`，模块落点在 `architecture.md`。
> **细则全文**在 `docs/rules/01`–`10`（与业务无关）。冲突时改细则、不改本文件的阈值与指向。

## 0. 细则索引（按需打开，不要整组贴进指针）

| 编号 | 文件 | 大块 |
|------|------|------|
| 00 | `docs/rules/00-how-to-read.md` | 如何读 |
| 01 | `docs/rules/01-code-standards.md` | 代码规范 |
| 02 | `docs/rules/02-logging.md` | 日志 |
| 03 | `docs/rules/03-engineering-principles.md` | 软件工程原则 |
| 04 | `docs/rules/04-layering-and-patterns.md` | 分层与设计模式 |
| 05 | `docs/rules/05-iteration.md` | 需求与 Bug 迭代 |
| 06 | `docs/rules/06-automated-testing.md` | 自动化测试 |
| 07 | `docs/rules/07-database.md` | 数据库 |
| 08 | `docs/rules/08-git.md` | Git |
| 09 | `docs/rules/09-deployment.md` | 部署 |
| 10 | `docs/rules/10-context-and-tokens.md` | 上下文与 tokens |

## 1. 量化阈值（超出必须拆分或书面豁免）

| 项 | 上限 |
|----|------|
| 函数 | 50 行 |
| UI 组件 | 250 行 |
| 单文件 | 400 行 |
| 嵌套层级 | 3 层 |
| 函数参数 | 5 个 |
| 重复代码 | ≥ 8 行必须抽取 |

禁止靠压行达标。分层方向、失败分类、日志脱敏、确认门分别见 04 / 03 / 02 / 05 与 `workflow.md`。
