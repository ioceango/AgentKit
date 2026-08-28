# CLAUDE.md — 入口指针（规约正文不在本文件）

> 本文件是 **Claude Code / Claude 系工具** 在本仓库的入口。
>
> **规约正文全部位于 `.agent/`，本文件只指路、不抄写条款。**
> 发生任何冲突，一律以 `.agent/` 为准。
>
> 产品名：**{{PROJECT_NAME}}**。

## 必读清单（开工前按序读完，不可跳过）

1. `.agent/README.md` — 单一事实源声明、工具入口映射、skills/MCP
2. `.agent/workflow.md` — 迭代流程与用户确认门（何时才允许改代码）
3. `.agent/constraints.md` — 能力边界与红线
4. `.agent/rules.md` — 工程规范硬约束（代码怎么写）
5. `.agent/architecture.md` — 系统架构与模块职责（改哪里）
6. `.agent/verification.md` — 验证命令、顺序与完成定义（何时算做完）
7. `.agent/design.md` — 视觉设计

细则展开见 `docs/rules/`。技能包权威目录：`.agent/skills/`。

## 验证入口

```bash
bash scripts/verify-agent.sh
```

## 维护规则

规约变更只改 `.agent/`；本文件为纯路标，禁止在其中新增、改写或扩写规则条款。
