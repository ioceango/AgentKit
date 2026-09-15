<!-- agent-kit-core: {{KIT_VERSION}} -->
# .agents/workflow.md — 迭代流程与用户确认门

> 本文件规定「什么时候才允许改业务代码」。这是最高优先级的流程约束。
> 展开见 `docs/rules/05-iteration.md` 与 `docs/rules/08-git.md`。

## 1. 强制流程（禁止跳步）

任何**需求**或**Bug 修复**，在写业务代码之前必须依次完成：

```
① 判定类型（需求 / Bug）
② 取下一个全局编号
③ 建编号目录
④ 写 spec.md
⑤ 【用户确认 spec】 ← 硬性门
⑥ 写 plan.md
⑦ 【用户确认 plan】 ← 硬性门
⑧ 生成 checklist.md
⑨ 才允许改业务代码
⑩ 按 .agents/verification.md 执行验证
⑪ 编号截图写入该迭代 `test-report/`（`S01-*.png` 起），在 `test-report.md` 按编号引用后归档
⑫ 登记索引；若本迭代改动了数据库表，同步项目表结构目录（若有）
⑬ 若仓库已有 `.git`：确保 `develop` 分支存在（没有则从 `main` 创建），在本迭代编号分支上提交并推送（见 §7）
⑭ 【用户确认测试通过】 ← 硬性门
⑮ 编号分支 `--no-ff` 合入 `develop`，并提醒用户本人从 `develop` 向 `main` 提 PR（agent 永不改 `main`）
```

**必须（always）**
- 在 ⑤、⑦ 与 ⑭ 三处停下来等用户确认，不得自行推进。
- 编号目录必须在写任何业务代码之前建立。
- 涉及表结构变更时，`plan.md` 写明表变更，并更新表结构目录（若项目有该文档）。

**禁止（never）**
- 未确认 `spec.md` / `plan.md` 就修改业务代码。
- 边写代码边补 spec，或事后倒推 spec。
- 跳过 `checklist.md` 直接进入编码。

## 2. 编号目录规范

| 类型 | 目录 | 命名格式 |
|------|------|---------|
| 需求 | `docs/features/` | `FEAT-<3位序号>-<英文短slug>/` |
| Bug | `docs/bug-fix/` | `BUG-<3位序号>-<英文短slug>/` |

规则：
1. 序号为 3 位数字，**全局单调递增、不复用、不回填**；需求与 Bug 各自独立计号。
2. slug 为英文小写 + 短横线，例如 `FEAT-005-batch-export`、`BUG-003-empty-list`。
3. 每个编号目录下**固定四份文档，缺一不可**：`spec.md`、`plan.md`、`checklist.md`、`test-report.md`。
4. 四份文档均不得留空、不得保留未完成标记。
5. 结构沿用 `docs/templates/{spec,plan,checklist,test-report}-template.md`。
6. 新增迭代必须登记到 `docs/features/README.md` 或 `docs/bug-fix/README.md` 索引表。
7. 目录一旦建立即为长期追溯资产，不得重命名或删除；作废迭代把状态改为「已废弃」并在 `spec.md` 写明原因。

## 3. 取号方法（先查再建）

```bash
ls docs/features   # 取现有最大 FEAT 号 + 1
ls docs/bug-fix    # 取现有最大 BUG 号 + 1
```

索引表底部的「下一个可用编号」为参考值，**建目录前仍须用上述命令复核**。

## 4. 各文档职责

| 文档 | 必须写清 |
|------|---------|
| `spec.md` | 背景与问题、目标与非目标、用户故事、功能需求、验收标准（AC 逐条可判定）、边界与约束、影响面 |
| `plan.md` | 技术方案与取舍、涉及文件清单（新增/修改/禁改）、分步实施顺序、数据与接口变更、风险与回滚 |
| `checklist.md` | 可勾选的完成项，覆盖功能、规范符合性、验证项、文档同步；豁免项写明理由 |
| `test-report.md` | 真实执行过的命令、退出码、输出摘要、AC 逐条对照、编号截图引用、遗留风险、最终结论 |

**测试报告红线**：只允许写**实际执行过**的验证结果。未执行的步骤必须显式标注为未执行/后续补齐，禁止编造命令输出、用例数量或结论。

**端到端 / 截图（每个 FEAT 与每个 BUG，细则见 `.agents/verification.md`）**
- 有 UI 的迭代必须跑端到端，禁止只靠 curl 或读代码宣称 UI 完成。
- 截图只许放在该迭代的 `test-report/` 子目录，文件名 `S<2位>-<slug>.png`。
- `test-report.md` 必须用表格引用全部编号截图，并标注覆盖的 AC。缺文件或未引用视为未完成。

## 5. Bug 修复附加要求

- `spec.md` 必须包含：复现步骤、根因分析（定位到具体文件与代码行为）、影响范围。
- 必须补一条回归用例，注释注明迭代编号（例如 `# BUG-002 回归`）。
- 禁止只改表象（例如只改提示文案）而不处理根因；若确实只能缓解，需在 `spec.md` 与 `test-report.md` 显式说明。

## 6. 归档与完成

- 迭代完成后把索引表状态改为「已完成」，并更新「下一个可用编号」。
- 架构变更同步 `.agents/architecture.md`。
- 完成定义见 `.agents/verification.md`。

## 7. Git 提交与分支（有 `.git` 时强制）

分支模型：`main` ← `develop` ← `feat|fix/<编号>-<slug>`。展开见 `docs/rules/08-git.md`。

**必须（always）**
- 开工前检查 `develop` 是否存在，没有就从 `main` 创建：`git checkout -b develop main`。
- 工作分支名含同一编号：`feat/FEAT-<3位>-<slug>` 或 `fix/BUG-<3位>-<slug>`，从 `develop` 切出。一条分支只做这一个编号。
- 提交与推送**默认只落在本迭代编号分支**，而不是 `main` 或 `develop`。
- 提交主题含已存在的 `FEAT-<3位>` 或 `BUG-<3位>`，格式：`<type>(FEAT-012): …` 或 `<type>(BUG-007): …`。一次 commit 只对应一个编号。
- 用户确认测试通过后，把编号分支 `--no-ff` 合入 `develop` 并删除工作分支，随后提醒用户本人从 `develop` 向 `main` 提 PR。

**禁止（never）**
- 把迭代提交直接做在 `main` 或 `develop` 上。
- 以任何方式把代码合入 `main`——merge、rebase、fast-forward、代提 PR 都不允许；`main` 只由用户本人从 `develop` 提 PR 更新。
- 用户未确认测试通过就把编号分支合入 `develop`。
- 无编号、编号目录尚不存在、或把多个 FEAT/BUG 打进同一次提交 / 同一条长期分支。
- 对 `main`、`develop` force-push；改写已推送历史。
- 提交 `.env`、密钥、客户数据或敏感正文、签名 URL。

无 `.git` 时不把「未 git commit」当作不合格。初始化仓库后的第一次提交也必须挂到某个已存在编号。
