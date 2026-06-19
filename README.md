# Skills（中文 fork）

本仓库 fork 自 [mattpocock/skills](https://github.com/mattpocock/skills)，**保留其全部 skill 文件原样**（便于持续从 `origin/main` 合并），并在此基础上新增了 [`zy/`](./skills/zy/) 一桶 skill，围绕 **Spec-Driven Development（SDD）** 流程做扩展与本地化改造。

这些 skill 的核心理念承袭自 matt：开工前用 grilling 对齐需求、用共享语言（`CONTEXT.md` + ADR）降低冗长、用 red-green-refactor 的反馈循环保证代码可运行、并持续投资代码架构。本 fork 在此之上补齐了一条 **grill → prd → spec → tdd → review → maintain** 的完整 SDD 流水线。

## 与 upstream 的关系

- **保留** matt 的 skill（`engineering/`、`productivity/`），文件不动。
- **新增** `zy/` 一桶；详见 [skills/zy/README.md](./skills/zy/README.md)。
- **取代策略**：当某个 `zy/` skill 完整取代一个 upstream skill 时，从 `.claude-plugin/plugin.json` 注销该 upstream 条目（**文件保留**，保持可合并）。目前已注销：

  | 已注销的 upstream skill | 取代它的 zy/ skill |
  | --- | --- |
  | `engineering/ask-matt` | [`/route`](./skills/zy/route/SKILL.md)（意图 → skill 路由器） |
  | `engineering/setup-matt-pocock-skills` | [`/setup-skills`](./skills/zy/setup-skills/SKILL.md)（本地-only） |
  | `engineering/to-prd` | [`/to-prd`](./skills/zy/to-prd/SKILL.md)（模型调用，可被编排） |
  | `engineering/tdd` | [`/tdd`](./skills/zy/tdd/SKILL.md)（纯实现） |
  | `engineering/to-issues` | [`/to-spec`](./skills/zy/to-spec/SKILL.md)（吸收其拆解职责） |
  | `productivity/handoff` | [`/handoff`](./skills/zy/handoff/SKILL.md)（模型调用，输出下个会话启动 prompt） |

## 安装

```bash
npx skills@latest add mattpocock/skills
```

挑选所需 skill（务必选 `/setup-skills`），再在 agent 里运行 `/setup-skills` 配置仓库：本地 markdown issue 追踪器、triage 标签、domain 文档布局、以及一份初始的项目级 CodeMap。

## 作为 Claude Code plugin 安装

本仓库同时是一个 Claude Code plugin marketplace（见 [.claude-plugin/marketplace.json](./.claude-plugin/marketplace.json)），可整体作为一个 plugin 安装，skill 命名空间为 `zy-skills:`。

**本地路径（开发/测试）：**

```bash
claude plugin marketplace add .
claude plugin install zy-skills@zy-skills
```

**从 GitHub：**

```bash
claude plugin marketplace add ZY-1999/skills
claude plugin install zy-skills@zy-skills
```

或在 Claude Code 交互模式里：`/plugin marketplace add .` → `/plugin install zy-skills@zy-skills`。安装后仍需运行 `/setup-skills` 完成仓库配置。

## Skill 清单

> **调用类型**：**用户调用** 只能由你键入触发，职责是编排；**模型调用** 可由你触发，也能在任务匹配时被 agent 自动选用，承载可复用的纪律。一个用户调用 skill 可以调用模型调用 skill，但不会调用另一个用户调用 skill。

### 来自 mattpocock（保留）

**Engineering**（日常代码工作）

- **[grill-with-docs](./skills/engineering/grill-with-docs/SKILL.md)** — grilling 会话，同时构建项目领域模型、打磨术语，并就地更新 `CONTEXT.md` 与 ADR。`（用户调用）`
- **[triage](./skills/engineering/triage/SKILL.md)** — 把 issue 在一组 triage 角色的状态机里流转。`（用户调用）`
- **[improve-codebase-architecture](./skills/engineering/improve-codebase-architecture/SKILL.md)** — 扫描代码库寻找深化机会，以可视化 HTML 报告呈现，再 grill 你选中的那条。`（用户调用）`
- **[prototype](./skills/engineering/prototype/SKILL.md)** — 搭一个一次性原型来厘清设计（可运行终端程序，或可在一个路由上切换的几种 UI 变体）。`（用户调用）`
- **[diagnosing-bugs](./skills/engineering/diagnosing-bugs/SKILL.md)** — 顽固 bug 与性能回归的纪律化诊断循环：复现 → 最小化 → 假设 → 插桩 → 修复 → 回归测试。`（模型调用）`
- **[domain-modeling](./skills/engineering/domain-modeling/SKILL.md)** — 主动构建并打磨项目领域模型——用词汇表挑战术语、用边界场景压测、就地更新 `CONTEXT.md` 与 ADR。`（模型调用）`
- **[codebase-design](./skills/engineering/codebase-design/SKILL.md)** — 设计深模块的共享纪律与词汇：大量行为藏在一个小接口后，放在干净的接缝处，可通过该接口测试。`（模型调用）`

**Productivity**（通用非代码工作流）

- **[grill-me](./skills/productivity/grill-me/SKILL.md)** — 围绕一个计划或设计被 relentless 地访谈，直到决策树每条分支都被解决。`（用户调用）`
- **[teach](./skills/productivity/teach/SKILL.md)** — 跨多次会话教用户一项新概念，以当前目录作为有状态的教学工作区。`（用户调用）`
- **[writing-great-skills](./skills/productivity/writing-great-skills/SKILL.md)** — 写好、改好 skill 的参考：让 skill 可预测的词汇与原则。`（用户调用）`
- **[grilling](./skills/productivity/grilling/SKILL.md)** — grill-me / grill-with-docs 背后可复用的 relentless 访谈循环。`（模型调用）`

### 本 fork 新增（zy/）

围绕 SDD 流水线新增，8 个；每个都可在 [skills/zy/README.md](./skills/zy/README.md) 查看完整说明。

- **[route](./skills/zy/route/SKILL.md)** — 意图 → skill 路由器：扫一眼你想做什么，拿到处理它的那一个 skill（或一条短链）。`（用户调用）`
- **[setup-skills](./skills/zy/setup-skills/SKILL.md)** — 为 SDD skills 配置仓库（本地 markdown issue 追踪器、triage 标签、domain 文档、初始 CodeMap）；`setup-matt-pocock-skills` 的本地-only 改造版。`（用户调用）`
- **[to-prd](./skills/zy/to-prd/SKILL.md)** — 把当前对话综合成 PRD 并发布到 issue 追踪器（不访谈，只综合）。`（模型调用）`
- **[to-spec](./skills/zy/to-spec/SKILL.md)** — 把 PRD / bug / 已 grilled 对话拆成 `spec`：原子、规划完备的单元，一个 spec = 一次 `/tdd` 会话。`（模型调用）`
- **[tdd](./skills/zy/tdd/SKILL.md)** — 用 red-green-refactor 实现一个规划完备的 spec（纯实现，无 planning 步骤）。`（模型调用）`
- **[codemap](./skills/zy/codemap/SKILL.md)** — 生成、更新或 drift-check agent 可读的 CodeMap（渐进式代码地形索引）。`（模型调用）`
- **[sdd-flow](./skills/zy/sdd-flow/SKILL.md)** — 端到端 SDD 编排器：grill → prd → spec → build → review → maintain，串接各阶段、管 git 检查点与人工关卡（spec 质量审查归 `/to-spec`，不归本 skill）。`（模型调用）`
- **[handoff](./skills/zy/handoff/SKILL.md)** — 把当前对话压缩成 OS 临时目录的 handoff 文件，并输出一条可直接粘贴的下个会话启动 prompt（「请阅读文件 <path> 然后继续 <action>」）。`（模型调用）`

### 其它

[`misc/`](./skills/misc/) 下另有几个未在 `plugin.json` 注册的辅助 skill（git 防护、测试断言迁移、脚手架、pre-commit 等），按需自取，不在上述清单内。
