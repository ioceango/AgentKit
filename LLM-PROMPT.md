# 给 LLM 的提示词：用 agent-kit 搭 vibe coding 骨架

把下面整段交给编码助手。把 `KIT`、`ROOT`、`NAME`、`SLUG` 换成真实路径与产品名。

---

你正在为目标仓库搭 **与业务无关的 vibe coding 骨架**（确认门、编号迭代、多工具纯路标、工业化细则 01–10）。不要把来源产品的业务代码、密钥或技术栈红线拷过去。

套件路径：`KIT` = `<path-to>/show/agent-kit`
目标根：`ROOT` = `<target-project-root>`
产品名：`NAME` = `<显示名>`
短名：`SLUG` = `<小写短横线，如 my-app>`

## 步骤

1. 确认 `ROOT` 存在（空目录或已有代码均可）。不要修改 `KIT` 以外的来源仓库业务文件。
2. 执行（不要交互询问已写在这里的参数）：

```bash
bash "$KIT/install-agent-kit.sh" --root "$ROOT" --name "$NAME" --slug "$SLUG"
```

可选（仅当目标仓已经有 Playwright MCP cli 时）：

```bash
bash "$KIT/install-agent-kit.sh" --root "$ROOT" --name "$NAME" --slug "$SLUG" \
  --with-mcp --mcp-cli <相对 ROOT 的 cli.js> --with-ci --with-review-skill
```

3. 看安装器打印的 `mode=`：
   - `empty`：新骨架。接着填写 overlay：`.agents/constraints.md`、`architecture.md`、`design.md`，以及 `.agents/verification.md` §1.1 的本栈命令。
   - `existing`：已有 vibe 骨架。overlay **不得覆盖**；只补缺的 core / `docs/rules/01–10`。若指针含 `## 关键红线摘要`，安装器会失败，你要报告而不是强行改指针条款。
4. 运行并汇报退出码：

```bash
bash "$ROOT/scripts/verify-agent.sh"
```

5. 禁止：把密钥写进 overlay；把 `docs/rules` 全文复制进 `AGENTS.md`；为套件在目标仓建 FEAT 目录（除非用户要改目标仓业务）。

通用细则（换项目仍遵守）：代码、日志、软件工程原则、分层与模式、迭代、测试、数据库、Git、部署、上下文/tokens。唯一要按项目改的是业务红线与技术栈落点（overlay）。
