<!-- agent-kit-core: {{KIT_VERSION}} -->
# 08 Git 提交规范

仓库还没有 `.git` 时，不把「未 commit」当成交付失败。一旦有 `.git`，本文件立即生效。

## 主题

```
<type>(<FEAT-NNN|BUG-NNN>): <不超过约 50 字的说明>
```

`type`：`feat` / `fix` / `docs` / `test` / `refactor`。禁止用无编号的 `wip`、`update`、`chore` 绕过目录制（初始化空提交除外，也须挂到已存在编号）。

一次提交只对应一个编号。主题里的编号必须已有 `docs/features` 或 `docs/bug-fix` 目录。

## 分支模型

```
main      ← 只由用户本人从 develop 提 PR 更新，agent 永不合入
 └─ develop ← 集成分支：feat / fix 经用户确认测试通过后合入
      ├─ feat/FEAT-<3位>-<slug>
      └─ fix/BUG-<3位>-<slug>
```

- 开工前必须检查 `develop` 是否存在：`git branch --list develop`（远端另查 `git ls-remote --heads origin develop`）。没有就从 `main` 创建：`git checkout -b develop main`，需要远端时 `git push -u origin develop`。
- 需求：`feat/FEAT-<3位>-<与目录相同的 slug>`；缺陷：`fix/BUG-<3位>-<与目录相同的 slug>`。编号分支必须从 `develop` 切出，一条分支只服务一个编号。
- 每次迭代完的提交与推送**默认落在本迭代的 feat / fix 分支**，禁止直接做在 `main` 或 `develop` 上。

## 合并门

- feat / fix → `develop`：**硬性门**。验证与测试报告完成后，必须等**用户确认测试没问题**，才允许 `git checkout develop && git merge --no-ff <工作分支>`；合入后删除工作分支。
- 任何分支 → `main`：**禁止 agent 操作**。即使用户已批准本次改动，`main` 也只能由用户本人从 `develop` 提 PR 更新。agent 不得以 merge、rebase、fast-forward、代提 PR 等任何方式改动 `main`；每次合入 `develop` 后应主动提醒用户去提 PR。

## 回滚

- 已推送：`git revert`，不改写历史；`develop` 上误合入用 `git revert -m 1 <merge-commit>`。
- 禁止对 `main`、`develop` force-push。
- 禁止对已推送提交 rebase -i / amend 后强推。

## 禁止纳入版本库

`.env`、真实密钥、证书私钥、客户数据或业务正文、依赖目录、构建产物、日志。误提交密钥必须按轮换处理，不能只再提交一版删除。
