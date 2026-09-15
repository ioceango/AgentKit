---
name: code-review
description: >
  Review this repository as four specialists (architect, backend, frontend,
  data). Use when the user asks for code review, 代码审查, review my changes,
  review this PR, or /code-review.
---

# Code review

只审不改，除非用户明确要求动手修。条款正文在 `.agents/` 与 `docs/rules/`；本 skill 只规定**怎么审、看什么、如何汇报**。先读本项目 `.agents/architecture.md` 再分视角，不要套用其它产品的表名或目录。

## 0. 开工

1. 圈定范围：用户点名的文件 / `FEAT-NNN` / `BUG-NNN` / 工作区改动。无 git 时读用户点名的路径，不要假装有 diff。
2. 若范围含编号，先读该目录 `spec.md`、`plan.md`，对照 AC。
3. 必读：`.agents/constraints.md` `.agents/architecture.md` `.agents/rules.md` `.agents/workflow.md`；涉及 UI 时读 `.agents/design.md`。
4. 四段都要过：即使本次只改前端，也要扫一眼是否误伤分层、归属或契约。某段无发现就写「本视角无阻塞项」，不要编问题凑数。

严重级别：`阻塞`（违反红线或会坏主路径）· `严重`（正确性/隔离/数据完整性）· `建议`（可维护性）。

## 1. 架构师

打开 `.agents/architecture.md`，按**本项目**模块图审查，不要假设特定云厂商或认证产品。

| 查 | 缺陷信号 |
|----|----------|
| 分层单向 | 路由层碰存储/外部 IO；领域层 import HTTP 框架；仓储做业务判断 |
| 无平行分层 | 为绕过职责新开一套包 |
| 迭代治理 | 改业务代码但无已确认 spec/plan；缺四文档 |
| 先问再做 | 新依赖/新密钥、破坏性结构变更、改公共 API、换技术栈且未在 plan 声明 |

## 2. 后端

打开 `.agents/constraints.md` 与 `.agents/rules.md`。

| 查 | 缺陷信号 |
|----|----------|
| 归属 | 信任请求体里的身份字段；查询不带 Owner 过滤 |
| 事务 | 长事务跨越外部网络或对象存储 |
| 配置 | 超时、模型名、限额硬编码 |
| 错误 | 一律同一内部错误码；对外返回堆栈/SQL/上游原文 |
| 测试 | Bug 无 `# BUG-NNN 回归`；单测打真实付费网关 |

## 3. 前端

打开 `.agents/architecture.md` 与 `.agents/design.md`。

| 查 | 缺陷信号 |
|----|----------|
| 出口 | 页面内散落裸 HTTP，不走项目声明的唯一客户端 |
| 失败 | 业务错误被误判成未登录整页踢出 |
| 视觉 | 另起一套皮肤或改公共 UI 组件对外 API |
| 流程 | 有 UI 的 FEAT/BUG 未跑端到端或截图不按 `test-report/S01-*.png` 归档 |

## 4. 数据

打开项目表结构目录（若有）与 `.agents/architecture.md` 的数据节。

| 查 | 缺陷信号 |
|----|----------|
| 注释与目录 | 改表不同步目录文档 |
| 隔离 | 跨用户能读到行；删除父行留下孤儿 |
| 事务 | 长事务跨外部调用 |

## 5. 横切

- 日志：密钥、签名 URL、业务正文全量、prompt 全文。
- Git：有 `.git` 时提交/分支是否带同一 `FEAT-NNN`/`BUG-NNN`。
- 测试报告：未执行却写通过。

## 6. 汇报格式

```markdown
## 结论
<一句话：能否合入 / 必须先修哪些阻塞>

## 范围
<文件或迭代编号>

## 发现
### [阻塞] 短标题
- 视角：架构 | 后端 | 前端 | 数据
- 位置：path:line
- 问题：…
- 依据：`.agents/…` 的哪一条
- 建议：…
```

无发现时明确写「四视角均无阻塞/严重项」。

## 7. 归档

写入对应编号目录 `review-report/R<2位>-<YYYY-MM-DD>.md`，模板见 `references/review-report-template.md`。禁止覆盖已有文件。
