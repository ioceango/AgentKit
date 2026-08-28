# Trae 规则入口指针（规约正文不在本文件）

> 本文件是 **Trae** 在本仓库 `.trae/rules/` 下的入口。
>
> **规约正文全部位于 `.agent/`，本文件只指路、不抄写条款。**
> 同时请读取仓库根 `AGENTS.md`。发生任何冲突，一律以 `.agent/` 为准。
>
> 产品名：**{{PROJECT_NAME}}**。

## 必读清单（开工前按序读完，不可跳过）

1. `.agent/README.md`
2. `.agent/workflow.md`
3. `.agent/constraints.md`
4. `.agent/rules.md`
5. `.agent/architecture.md`
6. `.agent/verification.md`
7. `.agent/design.md`

## 验证入口

```bash
bash scripts/verify-agent.sh
```

## 维护规则

规约变更只改 `.agent/`；本文件为纯路标，禁止在其中新增、改写或扩写规则条款。
