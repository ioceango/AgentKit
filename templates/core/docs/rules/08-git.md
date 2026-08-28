<!-- agent-kit-core: {{KIT_VERSION}} -->
# 08 Git 提交规范

仓库还没有 `.git` 时，不把「未 commit」当成交付失败。一旦有 `.git`，本文件立即生效。

## 主题

```
<type>(<FEAT-NNN|BUG-NNN>): <不超过约 50 字的说明>
```

`type`：`feat` / `fix` / `docs` / `test` / `refactor`。禁止用无编号的 `wip`、`update`、`chore` 绕过目录制（初始化空提交除外，也须挂到已存在编号）。

一次提交只对应一个编号。主题里的编号必须已有 `docs/features` 或 `docs/bug-fix` 目录。

## 分支

- 需求：`feat/FEAT-<3位>-<与目录相同的 slug>`
- 缺陷：`fix/BUG-<3位>-<与目录相同的 slug>`
- 一条分支只服务一个编号。合入默认分支后删除工作分支。

## 回滚

- 已推送：`git revert`，不改写历史。
- 禁止对默认分支 force-push。
- 禁止对已推送提交 rebase -i / amend 后强推。

## 禁止纳入版本库

`.env`、真实密钥、证书私钥、客户数据或业务正文、依赖目录、构建产物、日志。误提交密钥必须按轮换处理，不能只再提交一版删除。
