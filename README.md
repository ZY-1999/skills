# Skills（中文 fork）

本仓库 fork 自 [mattpocock/skills](https://github.com/mattpocock/skills)，**保留其全部 skill 文件原样**（便于持续从 `origin/main` 合并），并在此基础上新增了 [`zy/`](./skills/zy/) 一桶 skill，围绕 **Spec-Driven Development（SDD）** 流程做扩展与本地化改造。

这些 skill 的核心理念承袭自 matt：开工前用 grilling 对齐需求、用共享语言（`CONTEXT.md` + ADR）降低冗长、用测试先行的反馈循环保证代码可运行、并持续投资代码架构。本 fork 在此之上补齐了一条完整 SDD 流水线，文档分四层（参考 mumu-spec 的分层与对齐思想，裁剪为个人可用的体量）：

```
PRD（纯需求：AC 编号 + P0/P1）
  └─ contracts.md（技术契约真源：C-NN 端点/错误码/字段）      ← /to-spec 双锚对齐产出
      └─ specs/（执行切片：AC 投影 + 契约引用 + 增量设计）
          └─ trace.md（追溯矩阵：AC→场景→契约→spec→test→commit）
```

流程：**grill → prd → [Gate 0 卡] → align(contracts+trace) → specs → [Gate A 卡] → tdd(场景驱动) → review+追溯门禁 → maintain**；人只在两道门各看一张一屏卡片并抽查一个最高风险 spec，`/tdd` 收尾免逐条确认。需求变更走 `/spec-sync` 联动下游，`/spec-check` 四维质检 + 看板兜底。

## 与 upstream 的关系

- **保留** matt 的 skill（`engineering/`、`productivity/`），文件不动。
- **新增** `zy/` 一桶；详见 [skills/zy/README.md](./skills/zy/README.md)。
- **取代策略**：当某个 `zy/` skill 完整取代一个 upstream skill 时，从 `.claude-plugin/plugin.json` 注销该 upstream 条目（**文件保留**，保持可合并）。目前已注销：

  | 已注销的 upstream skill                     | 取代它的 zy/ skill                                                                                                                           |
  | ------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
  | `engineering/ask-matt`                      | [`/route`](./skills/zy/route/SKILL.md)（意图 → skill 路由器）                                                                                |
  | `engineering/setup-matt-pocock-skills`      | [`/setup-skills`](./skills/zy/setup-skills/SKILL.md)（本地-only）                                                                            |
  | `engineering/to-prd`                        | [`/to-prd`](./skills/zy/to-prd/SKILL.md)（模型调用，可被编排）                                                                               |
  | `engineering/tdd`                           | [`/tdd`](./skills/zy/tdd/SKILL.md)（纯实现）                                                                                                 |
  | `engineering/to-issues`                     | [`/to-spec`](./skills/zy/to-spec/SKILL.md)（吸收其拆解职责）                                                                                 |
  | `productivity/handoff`                      | [`/handoff`](./skills/zy/handoff/SKILL.md)（模型调用，输出下个会话启动 prompt）                                                              |
  | `engineering/improve-codebase-architecture` | [`/improve-architecture`](./skills/zy/improve-architecture/SKILL.md)（架构发现，产出 needs-info 草稿即止；ICA 的 grilling 设计由 `/to-spec` + Gate A 替代） |
  | `engineering/diagnosing-bugs`               | [`/diagnose-bug`](./skills/zy/diagnose-bug/SKILL.md)（诊断循环，止于确认根因、交付诊断；保留 Phase 1-4 诊断纪律）                          |

## 作为 Claude Code plugin 安装

本仓库同时是一个 Claude Code plugin marketplace（见 [.claude-plugin/marketplace.json](./.claude-plugin/marketplace.json)），可整体作为一个 plugin 安装，skill 命名空间为 `zy-skills:`。

**本地路径（开发/测试）：**

```bash
claude plugin marketplace add ./
claude plugin install zy-skills@zy-skills
```

**从 GitHub：**

```bash
claude plugin marketplace add ZY-1999/skills
claude plugin install zy-skills@zy-skills
```

或在 Claude Code 交互模式里：`/plugin marketplace add .` → `/plugin install zy-skills@zy-skills`。安装后仍需运行 `/setup-skills` 完成仓库配置。

### Hook：提交前 review 门禁（v1.0.2 新增）

插件自带一个 PreToolUse hook（[hooks/](./hooks/)）：在**跑过 `/setup-skills` 的仓库**里，agent 通过 Bash 执行 `git commit` 时会被拦截，要求先对未提交变更跑 `/review`；两个轴都无硬性违规时 `/review` 会把当前 diff 的哈希写入 `.git/zy-skills-review-approved`，随后重试同一提交即可放行（标记一次性消费，diff 一变即失效需重新 review）。

- 只约束 ZCode / Claude Code 会话内 agent 发起的提交；你在自己终端手动 `git commit` 不受影响，是天然的逃生通道。
- 未跑过 `/setup-skills` 的仓库（没有 `docs/agents/issue-tracker.md`）完全不生效，插件可安全全局安装。

## Skill 清单

> **调用类型**：**用户调用** 只能由你键入触发，职责是编排；**模型调用** 可由你触发，也能在任务匹配时被 agent 自动选用，承载可复用的纪律。一个用户调用 skill 可以调用模型调用 skill，但不会调用另一个用户调用 skill。

### 来自 mattpocock（保留）

**Engineering**（日常代码工作）

- **[grill-with-docs](./skills/engineering/grill-with-docs/SKILL.md)** — grilling 会话，同时构建项目领域模型、打磨术语，并就地更新 `CONTEXT.md` 与 ADR。`（用户调用）`
- **[prototype](./skills/engineering/prototype/SKILL.md)** — 搭一个一次性原型来厘清设计（可运行终端程序，或可在一个路由上切换的几种 UI 变体）。`（用户调用）`
- **[domain-modeling](./skills/engineering/domain-modeling/SKILL.md)** — 主动构建并打磨项目领域模型——用词汇表挑战术语、用边界场景压测、就地更新 `CONTEXT.md` 与 ADR。`（模型调用）`
- **[codebase-design](./skills/engineering/codebase-design/SKILL.md)** — 设计深模块的共享纪律与词汇：大量行为藏在一个小接口后，放在干净的接缝处，可通过该接口测试。`（模型调用）`

**Productivity**（通用非代码工作流）

- **[grill-me](./skills/productivity/grill-me/SKILL.md)** — 围绕一个计划或设计被 relentless 地访谈，直到决策树每条分支都被解决。`（用户调用）`
- **[teach](./skills/productivity/teach/SKILL.md)** — 跨多次会话教用户一项新概念，以当前目录作为有状态的教学工作区。`（用户调用）`
- **[writing-great-skills](./skills/productivity/writing-great-skills/SKILL.md)** — 写好、改好 skill 的参考：让 skill 可预测的词汇与原则。`（用户调用）`
- **[grilling](./skills/productivity/grilling/SKILL.md)** — grill-me / grill-with-docs 背后可复用的 relentless 访谈循环。`（模型调用）`

### 本 fork 新增（zy/）

围绕 SDD 流水线新增，14 个；每个都可在 [skills/zy/README.md](./skills/zy/README.md) 查看完整说明。

- **[route](./skills/zy/route/SKILL.md)** — 意图 → skill 路由器：扫一眼你想做什么，拿到处理它的那一个 skill（或一条短链）。`（用户调用）`
- **[setup-skills](./skills/zy/setup-skills/SKILL.md)** — 为 SDD skills 配置仓库（本地 markdown issue 追踪器、triage 标签、domain 文档、初始 CodeMap）；`setup-matt-pocock-skills` 的本地-only 改造版。`（用户调用）`
- **[improve-architecture](./skills/zy/improve-architecture/SKILL.md)** — 扫描代码库寻找架构深化机会，以可视化 HTML 报告呈现候选并发布到 issue tracker；**只做发现不做设计**（不跑 PRD 综合），每个候选（含 Top recommendation）直接作为 `needs-info` 轻量草稿落 issue tracker，留待后续 grill 完善。`（用户调用）`
- **[diagnose-bug](./skills/zy/diagnose-bug/SKILL.md)** — 顽固 bug 与性能回归的纪律化诊断循环：构建反馈循环 → 复现最小化 → 假设 → 插桩锁定根因，交付确认的诊断本身（不修复、不自动接力）。`（模型调用）`
- **[to-prd](./skills/zy/to-prd/SKILL.md)** — 把当前对话综合成父项 issue 并发布到 issue 追踪器（不访谈，只综合）：feature → `prd`（纯需求文档，AC 编号 + P0/P1）、bug → `bug`、架构深化 → `prd`（architecture 模板）。`（模型调用）`
- **[to-spec](./skills/zy/to-spec/SKILL.md)** — 把 PRD / bug / 已 grilled 对话翻译并拆解：先把 AC 双锚对齐成 `contracts.md`（技术契约真源）并播种 `trace.md` 场景矩阵，再 best-of-N 拆成 `spec`（AC 投影 + 契约引用）；一个 spec = 一次 `/tdd` 会话。`（模型调用）`
- **[tdd](./skills/zy/tdd/SKILL.md)** — 场景驱动实现一个规划完备的 spec：测试来自 `trace.md` 的 P0 场景（需求侧产物，非实现者自造）——逐场景 red → tracer-bullet green → 重构；切片内单测自由裁量；收尾免逐条确认，回填 trace。`（模型调用）`
- **[review](./skills/zy/review/SKILL.md)** — 自某个固定点（commit/branch/tag/merge-base）对 diff 做双轴复核：Standards（是否遵循仓库编码规范）+ Spec（是否忠实实现 spec，以 `contracts.md`/`trace.md` 为接口与覆盖真源）；两轴并行 fresh-context 子代理跑，分轴并排报告、不跨轴合并。v1.0.2 起 agent 的 `git commit` 被插件门禁拦截后，也由它复核未提交变更并无硬性违规时放行。`（模型调用）`
- **[spec-sync](./skills/zy/spec-sync/SKILL.md)** — 变更联动：需求或契约改动时，以 `contracts.md` 为中心列出全部需联动的下游（AC/场景/spec/测试/trace 行），确认后一并更新并重跑双锚互校。`（模型调用）`
- **[spec-check](./skills/zy/spec-check/SKILL.md)** — 四维质检 + 状态看板：完整性/一致性/追溯性/分层纯度，P0/P1 分级报告；fresh-context 子代理只读审计。`（模型调用）`
- **[codemap](./skills/zy/codemap/SKILL.md)** — 生成、更新或 drift-check agent 可读的 CodeMap（渐进式代码地形索引）。`（模型调用）`
- **[idea-to-prd](./skills/zy/idea-to-prd/SKILL.md)** — SDD 流水线前半段：从想法/需求出发，grill 对齐设计 → 综合 PRD → 人审 Gate 0（一屏卡片：P0 AC + 范围外 + 关键取舍），止于已批准的 PRD；是否接力 `/sdd-flow` 走 SDD 开发由 `/route` 决定。只负责 grill + PRD + Gate 0，不碰 git。`（模型调用）`
- **[sdd-flow](./skills/zy/sdd-flow/SKILL.md)** — SDD 流水线后半段：从已批准的 PRD 到交付。入口把 PRD 翻转为 `ready-for-agent`，然后 `/to-spec` 对齐拆解 → Gate A（一屏对齐卡 + 抽查一个最高风险 spec）→ `/tdd` 逐个场景驱动实现 → `/review` + 追溯门禁（全 P0 场景绿）→ 维护文档收尾。承接已批准的 PRD（Gate 0 后）或手写 PRD。`（模型调用）`
- **[handoff](./skills/zy/handoff/SKILL.md)** — 把当前对话压缩成 OS 临时目录的 handoff 文件，并输出一条可直接粘贴的下个会话启动 prompt（「请阅读文件 <path> 然后继续 <action>」）。`（模型调用）`

### 其它

[`misc/`](./skills/misc/) 下另有几个未在 `plugin.json` 注册的辅助 skill（git 防护、测试断言迁移、脚手架、pre-commit 等），按需自取，不在上述清单内。
