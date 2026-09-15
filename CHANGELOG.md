# Changelog

## 1.2.0

- **破坏性**：治理目录更名 `.agent/` → `.agents/`，对齐 AI 工具生态的 `.agents/skills/` 标准发现路径；
  覆盖 core/overlay 模板、adapters、installer 映射/断言/文案、门禁模板与细则文本。历史 changelog 条目保留旧名。
- opencode：项目技能（`.agents/skills/`）不再需要 `skills.paths` 桥接，默认发现路径直接生效。
- Git 规约引入三分支模型 `main / develop / feat|fix 编号分支`：开工前检查并自动从 `main` 创建 `develop`；每次迭代默认只提交到本迭代编号分支；用户确认测试通过后才合入 `develop`；`main` 一律由用户本人从 `develop` 提 PR 更新，禁止 agent 以任何方式合入。

## 1.1.0

- core 增加与业务无关的 `docs/rules/00`–`10`（代码、日志、工程原则、分层与模式、迭代、测试、数据库、Git、部署、上下文/tokens）。
- `LLM-PROMPT.md`：空仓或已有骨架时让模型执行安装器。
- 安装器打印 `mode=empty|existing`；门禁校验十条细则非空。
- `.agent/rules.md` 改为执行口 + 索引，避免与细则双源。

## 1.0.0

- 从治理核抽出可安装套件：`.agent/` 七文件、纯路标指针、`verify-agent.sh`。
- overlay 仅为占位，不含来源产品的认证/存储/文件限额红线。
- 可选：`--with-mcp`（必须同时给 `--mcp-cli`）、`--with-ci`、`--with-review-skill`。
