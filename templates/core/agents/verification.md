<!-- agent-kit-core: {{KIT_VERSION}} -->
# .agents/verification.md — 验证命令、顺序与完成定义

> 本文件规定「何时算做完」。顺序不得调换，步骤不得跳过。
> 栈相关命令（语言、包管理器、e2e 启动方式）由项目在 §1.1 维护；升级 core 时请手工合并该节。
> 通用测试流程见 `docs/rules/06-automated-testing.md`。

## 1. 验证顺序

```bash
# ⓿ 文档合规 gate（.agents 规约 + 工具指针 + 编号目录 + 索引登记）
bash scripts/verify-agent.sh
```

规则：
- ⓿ 未通过时**禁止**进入任何代码验证步骤，也禁止宣称完成。
- 任一步失败必须修复后**从该步重跑**，不得跳过继续。
- 同一问题修复 3 次仍失败，停止并上报阻塞原因与已尝试方案。
- 模块解析类错误（`Could not resolve`、`Cannot find module`、`Module not found`）为硬门禁，必须清零。

### 1.1 项目验证命令（由项目维护）

在 ⓿ 通过之后，按本项目技术栈追加静态检查、单元测试、构建与端到端。把真实命令写在这里，例如 lint、test、build、e2e。未填写时不得把「代码验证已通过」写进测试报告。

## 2. 文档合规 gate 判定项

由 `scripts/verify-agent.sh` 执行：

| 判定项 | 不合规表现 |
|--------|-----------|
| `.agents/` 规约齐全 | 必需文件（README / architecture / rules / constraints / workflow / verification / design）缺失或为空 |
| 工具指针有效 | `AGENTS.md`、`CLAUDE.md`、`.grok/rules/00-<slug>-rules.md`、`.trae/rules/00-<slug>-rules.md` 缺失、为空、未指向 `.agents/`、或含红线条款拷贝 |
| 编号目录命名 | 不匹配 `FEAT-<3位>-<小写slug>` / `BUG-<3位>-<小写slug>` |
| 四文档齐全 | 缺少 spec / plan / checklist / test-report 任一份 |
| 文档非空 | 文件存在但内容为空 |
| 未完成标记 | 编号目录文档仍保留未完成占位标记 |
| 索引登记 | 编号目录未出现在对应索引表 |
| 编号唯一 | 同一编号出现多个目录 |

全部问题项一次性汇总输出，便于一轮修完。

## 3. 测试要求

- 每个 Bug 修复至少一条回归用例，注释注明迭代编号。
- 外部模型 / 付费 API 一律 mock。
- 覆盖正常路径、边界、异常分类与可重试性、脱敏断言。
- 报告只写真实执行过的结果；未执行项显式标注为未执行/后续补齐。

### 3.1 端到端与编号截图（有 UI 的 FEAT / BUG 强制）

1. 跑与本迭代验收标准对应的端到端用例（优先 Playwright；MCP 未挂载时用项目内 CLI）。
2. 截图落到**该迭代目录下的 `test-report/` 子目录**：

```
docs/features/FEAT-00X-<slug>/
├── spec.md
├── plan.md
├── checklist.md
├── test-report.md
└── test-report/
    ├── S01-<短slug>.png
    └── S02-<短slug>.png
```

Bug 迭代同理：`docs/bug-fix/BUG-00X-<slug>/test-report/`。

3. 文件名必须匹配 `S<2位序号>-<英文短slug>.png`，序号从 `S01` 起连续。
4. `test-report.md` 必须有「编号截图」表，每一张列出编号、相对路径、覆盖的 AC、画面说明。
5. 截图必须覆盖本迭代的主路径与至少一条失败/边界路径。

**豁免**：仅当本迭代零 UI（纯后端/纯文档）时，可在 `checklist.md` 豁免项写明理由并获用户确认。

## 4. 完成定义（DoD）

- [ ] 编号目录存在且命名合规，四份文档齐全且无未完成标记
- [ ] `spec.md`、`plan.md` 已获用户确认
- [ ] `checklist.md` 全部勾选（豁免项写明理由并获确认）
- [ ] 对应索引表已登记本迭代并更新状态
- [ ] `bash scripts/verify-agent.sh` 通过
- [ ] §1.1 中由项目声明的代码验证已真实执行并通过
- [ ] 有 UI 则端到端通过，截图已落入 `test-report/` 且在 `test-report.md` 按编号引用
- [ ] `test-report.md` 附真实命令输出摘要，结论为通过或有条件通过
- [ ] 新增/变更配置已写入项目的配置样例文件（若有）
- [ ] 架构有变化时已同步 `.agents/architecture.md`

以上任一项未达成，不得宣称完成。
