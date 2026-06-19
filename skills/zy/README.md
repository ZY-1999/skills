# ZY

我自己的 skills —— 在本 fork 的 upstream mattpocock skills 基础上做的扩展与改造。

## 规则

- **绝不编辑 upstream skill 文件**（`engineering/`、`productivity/`、`misc/`、`personal/`、`in-progress/`、`deprecated/`）。upstream 保持原样，以便能从 `origin/main` 干净地 merge。
- 想改变某个 upstream skill 的行为，就在**这里新建一个 skill**，而不是改原文件。给它取一个**全新的 `name:`** —— 不要复用 upstream skill 的 `name:` frontmatter，保证 plugin 加载不产生歧义。
- 全新的 skill 也放在这里。

## 使用模型

终端用户通过 `npx skills add` 安装本仓库的 skills，并**按需挑选子集** —— 不会运行全部。upstream skills（`engineering/`、`productivity/`…）与 `zy/` skills 在同一条流程里**混用**：例如 `grill-with-docs`（upstream）→ `to-spec`（zy/）→ `tdd`（zy/）。

由此对每个 `zy/` skill 的要求：

- **与 upstream 互通是默认前提。** 用名字引用 upstream skills（`/grill-with-docs`、`/triage`…）—— 永远不要假设用户只装了 `zy/` skills。
- **共享 upstream 的配置格式。** `zy/` skills 读取 upstream `setup-matt-pocock-skills` 写入的同一批 `docs/agents/*.md`，所以两种 setup 任选其一都能配好两边。`zy/` skills 指向 `/setup-skills`（本地-only 版本）；产物互相兼容。
- **显式声明前置条件。** 每个 skill 列出自己需要什么（setup 配置、典型前置、消费者），让挑子集的用户知道还得装什么。
- **"替代"指功能重叠，不是删除。** 一个 `zy/` skill 可能与某个 upstream skill 重叠（如 `to-spec` ≈ `to-prd` + `to-issues`），但 upstream skill 仍留在仓库里 —— 用户照样可以选它。

## Issue 类型

每个被追踪的工作项都是一个 **issue**，每个 issue 承载且仅承载一种类型：

- **spec** —— agent 编码的原子单元。`/tdd` 在一次会话里实现的最小单位。一个**叶子**：不再被进一步拆解。由 `/to-spec` 产出。
- **prd** —— 产品需求文档。一个**父项**：`/to-spec` 把它拆成一个或多个 `spec`。
- **bug** —— bug 报告。一个**父项**：当修复需要多个编码步骤时，`/to-spec` 把它拆成 `spec`。

关系：

- `prd` 与 `bug` 是父项；`spec` 是叶子。
- 只有 `spec` 会被实现（通过 `/tdd`）。`prd`/`bug` 是规划/分诊产物。
- 一个 `spec` 带有指向其来源 `prd`/`bug` 的 `Parent:` 引用（来源是一次原始 grilled 对话时省略）。
- 对于没有现成 `prd` 的 grilled 对话，`/to-spec` 会内联合成设计并直接产出 `spec` —— 不需要 `prd` 产物。

issues 以本地 markdown 形式存于 `.scratch/<YYYY-MM-DD>-<feature-slug>/` 下，每个以 `Type:`（`spec | prd | bug`）开头。只有 `spec` 放进 `specs/` 子目录；`prd`/`bug` 作为父项放在与 `specs/` 同级的 feature 根目录。见 [issue-tracker-local.md](./setup-skills/references/issue-tracker-local.md)。

## 注册

- 本桶的 skills 以**增量**方式注册在 `.claude-plugin/plugin.json`；当一个 `zy/` skill 完整取代某个 upstream skill 时，**注销**该 upstream 条目（文件保留，便于从 `origin/main` 干净合并）。已注销清单见顶层 [README.md](../../README.md) 的"取代策略"表。
- zy/ skills 也列入顶层 `README.md` 的「本 fork 新增」清单；本 README 是它们的详细索引。
- 本桶不出现在任何 upstream bucket 列表里；它是 fork-local 的。

## 用户调用（User-invoked）

- **[route](./route/SKILL.md)** —— 意图 → skill 路由器：扫一眼你想做什么，拿到处理它的那一个 skill（或一条短链）。覆盖本 fork 实际解析的全部 skills —— zy/ 的 SDD skills 加上与之互通的 upstream skills。是索引，不是流程叙事；端到端执行在 `/sdd-flow`。
- **[setup-skills](./setup-skills/SKILL.md)** —— 为 SDD skills 配置仓库：本地 markdown issue 追踪器、triage 标签词汇、domain 文档布局，以及一份初始的项目级 CodeMap。`setup-matt-pocock-skills` 的本地-only 改造版（无 GitHub/GitLab）。在其他 SDD skills 之前运行一次。

## 模型调用（Model-invoked）

- **[to-prd](./to-prd/SKILL.md)** —— 把当前对话转成 PRD 并发布到 issue 追踪器 —— 不做访谈，只做综合。upstream `to-prd` 的模型调用改造版（setup 指向 `/setup-skills`），以便被 SDD flow 编排。产出供 `/to-spec` 拆解的 `prd` 父项。
- **[to-spec](./to-spec/SKILL.md)** —— 把一个 PRD、一个 bug、或当前（已 grilled 的）对话拆成 `spec` —— 原子的、**规划完备**的单元，agent 在一次 `/tdd` 会话里实现。拆分方案与每个复杂 spec 的设计都走 best-of-N + judge；拆分定案后先把 spec 骨架落库（`needs-design`），再逐个设计填充，设计完置 `ready-for-agent`。每个 spec 自带计划（接口变更、按优先级排列的待测行为、deep-module 备注），所以 `/tdd` 直接从 red-green 开始。替代 upstream `to-issues` 并吸收 upstream `tdd` 的 Planning 步骤。以 `/to-prd` 产出的 `prd`（或一个 bug、或一次 grilled 对话）作为父项输入。位于 `/grill-with-docs`/`/to-prd` 与 `/tdd` 之间。
- **[tdd](./tdd/SKILL.md)** —— 用测试先行（red-green-refactor）实现一个规划完备的 spec。纯实现：`/to-spec` 给出的 spec 已带好接口和按优先级排列的行为，所以这个 skill 直接从 tracer bullet 开始 —— 没有 planning 步骤。完全替代 upstream `tdd`（planning 已移到 `/to-spec`）。位于 `/to-spec` 之后。
- **[codemap](./codemap/SKILL.md)** —— 生成、更新或 drift-check agent 可读的 CodeMaps：渐进式代码地形索引，能把 agent 引到带源码链接的证据，而不必加载整个仓库。项目级（广度优先）或特性级（深度优先）地图，位于 `docs/codemap/`。喂给 `/to-spec` 的 "reduce chaos" 步骤，以及任何需要先看地形的 skill。改编自 `sdd-riper`。
- **[sdd-flow](./sdd-flow/SKILL.md)** —— 端到端 SDD 编排器：grill → prd → spec → build → review → maintain。只负责交接、git 检查点（首次写文件前建 `feature/<slug>`/`bugfix/<slug>` 分支；每个 gate 与每个 spec 完成后各 commit）与人工关卡（gate 时指向已落库的 spec 文件让用户 review）；spec 质量由 `/to-spec` 自带的两层 best-of-N（拆分 + 复杂 spec 设计）保证，不归本 skill。每个阶段都委托给对应 skill。模型调用；自动串起整条流水线（grill → prd → spec → build）—— grill 用模型调用的 `/grilling` + `/domain-modeling` 核心，而非用户调用的 `/grill-with-docs`；`/handoff` 现为模型调用，收尾时直接调用生成下个会话启动 prompt；对用户调用的 `/triage` 只读取 / 建议。

- **[handoff](./handoff/SKILL.md)** —— 把当前对话压缩成 OS 临时目录的 handoff 文件，并输出一条可直接粘贴的下个会话启动 prompt（「请阅读文件 <path> 然后继续 <action>」）。upstream `handoff` 的模型调用改造版（不再 user-only，可被 `/sdd-flow` 收尾时调用），并新增 emit starter prompt 一步。
