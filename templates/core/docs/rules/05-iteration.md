<!-- agent-kit-core: {{KIT_VERSION}} -->
# 05 需求与 Bug 迭代流程

执行顺序以 `.agents/workflow.md` 为准。本文是展开。

## 硬门

未确认 `spec.md` 与 `plan.md` **不得**改业务代码。禁止边写边补 spec，禁止跳过 checklist。

## 编号目录

| 类型 | 目录 | 命名 |
|------|------|------|
| 需求 | `docs/features/` | `FEAT-<3位>-<小写短横线slug>/` |
| 缺陷 | `docs/bug-fix/` | `BUG-<3位>-<小写短横线slug>/` |

每目录固定四份：`spec.md` `plan.md` `checklist.md` `test-report.md`，非空、无未完成占位，并登记对应 README 索引。序号全局递增、不复用。作废只改状态为「已废弃」，不删目录。

取号：先 `ls` 再 +1，不轻信索引底部「下一个编号」。

## 文档职责

| 文档 | 写什么 |
|------|--------|
| spec | 做什么、AC 可判定、非目标；Bug 还要复现步骤与根因（具体文件行为） |
| plan | 怎么做、改哪些文件、数据/接口、风险回滚 |
| checklist | 与 AC 一一对应，豁免写理由 |
| test-report | **只写真跑**的命令、退出码、摘要；未跑必须标明未执行 |

## Bug 附加

必须补回归用例并在注释写迭代号。禁止只改文案不修根因；只能缓解时在 spec 与报告里写明。

## Git

有 `.git` 时提交主题与分支带同一 `FEAT-NNN` 或 `BUG-NNN`。分支模型 `main ← develop ← 编号分支`：开工前检查 `develop`（没有就从 `main` 创建），编号分支从 `develop` 切出，迭代默认只提交到编号分支；**用户确认测试通过**后才合入 `develop`；`main` 只由用户本人从 `develop` 提 PR 更新，agent 永不合入。见 `08-git.md`。
