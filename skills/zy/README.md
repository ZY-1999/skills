# ZY

我自己的 skills —— 在本 fork 的 upstream mattpocock skills 基础上做的扩展与改造。

## 规则

- **绝不编辑 upstream skill 文件**（`engineering/`、`productivity/`、`misc/`、`personal/`、`in-progress/`、`deprecated/`）。upstream 保持原样，以便能从 `origin/main` 干净地 merge。
- 想改变某个 upstream skill 的行为，就在**这里新建一个 skill**，而不是改原文件。给它取一个**全新的 `name:`** —— 不要复用 upstream skill 的 `name:` frontmatter，保证 plugin 加载不产生歧义。
- 全新的 skill 也放在这里。

## 使用模型

本仓库作为 Claude Code plugin 安装（见顶层 [README.md](../../README.md)），`zy/` skills 以 `zy-skills:` 命名空间整体加载 —— 但 skills **不会全部运行**，只在被显式调用时触发。upstream skills（`engineering/`、`productivity/`…）随仓库文件保留但不随 plugin 激活（取代记录见顶层 README），用户可另行通过 `npx skills add mattpocock/skills` 装原版，于是 upstream 与 `zy/` skills 会在同一条流程里**混用**：例如 `grill-with-docs`（upstream）→ `to-spec`（zy/）→ `tdd`（zy/）。

由此对每个 `zy/` skill 的要求：

- **与 upstream 互通是默认前提。** 用名字引用 upstream skills（`/grill-with-docs`、`/domain-modeling`…）—— 永远不要假设用户只装了 `zy/` skills。
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
- 一个 `spec` 带有指向其来源 `prd`/`bug` 的 `Parent:` 引用（来源是一次 grilled 对话或直入的简单完整需求时省略）。
- 对于没有现成 `prd` 的 grilled 对话，`/to-spec` 会内联合成设计并直接产出 `spec` —— 不需要 `prd` 产物；简单且完整的需求也可经入口完整性门直入 `/to-spec`，不过门则退回 `/grill-me` / `/to-prd`。

## Feature 级产物（四层文档）

一个被拆解过的 feature 文件夹除 issue 外还带两个 feature 级产物（由 `/to-spec` 落地、`/tdd` 回填、`/spec-sync` 联动、`/spec-check` 审计）：

- **`contracts.md`** —— 技术契约真源：契约点 `C-NN`（端点 + 错误码 / 字段 + 约束），spec 与 trace 只引用 ID、不复制定义；数字与 PRD AC 严格一致（双锚对齐）。
- **`trace.md`** —— 追溯矩阵：`AC → 场景(S-NN) → 契约点 → spec → test → commit`。硬门禁：每个 P0 AC 必须有场景且最终 Test/Commit 非空；`/sdd-flow` Stage 3 按此收口。

分层不混层：PRD 只写需求语言（AC 不含 JSON/schema），contracts 只写契约不写叙事。

issues 以本地 markdown 形式存于 `.scratch/<YYYY-MM-DD>-<feature-slug>/` 下，每个以 `Type:`（`spec | prd | bug`）开头。只有 `spec` 放进 `specs/` 子目录；`prd`/`bug` 作为父项放在与 `specs/` 同级的 feature 根目录。见 [issue-tracker-local.md](./setup-skills/references/issue-tracker-local.md)。

## 注册

- 本桶的 skills 以**增量**方式注册在 `.claude-plugin/plugin.json`；当一个 `zy/` skill 完整取代某个 upstream skill 时，**注销**该 upstream 条目（文件保留，便于从 `origin/main` 干净合并）。已注销清单见顶层 [README.md](../../README.md) 的"取代策略"表。
- zy/ skills 也列入顶层 `README.md` 的「本 fork 新增」清单；本 README 是它们的详细索引。
- 本桶不出现在任何 upstream bucket 列表里；它是 fork-local 的。

## 用户调用（User-invoked）

- **[route](./route/SKILL.md)** —— 意图 → skill 路由器：扫一眼你想做什么，拿到处理它的那一个 skill（或一条短链）。覆盖本 fork 实际解析的全部 skills —— zy/ 的 SDD skills 加上与之互通的 upstream skills。是索引，不是流程叙事；跨段接力决策也在这里体现：已批准 PRD 是否继续 SDD 开发 → `/sdd-flow`，诊断是否转 tracked fix → `/to-prd` → `/sdd-flow`，简单且完整的需求是否跳过 grill/PRD 直连 → `/to-spec` → `/tdd`。
- **[setup-skills](./setup-skills/SKILL.md)** —— 为 SDD skills 配置仓库：本地 markdown issue 追踪器、triage 标签词汇、domain 文档布局，以及一份初始的项目级 CodeMap。`setup-matt-pocock-skills` 的本地-only 改造版（无 GitHub/GitLab）。在其他 SDD skills 之前运行一次。
- **[improve-architecture](./improve-architecture/SKILL.md)** —— 架构发现：扫描代码库寻找深化机会，以可视化 HTML 报告呈现候选，发布到 issue tracker 的新 feature 文件夹（`.scratch/<YYYY-MM-DD>-architecture-review-<HHmmss>/`）。**只做发现不做设计**（不 propose interfaces，不跑 PRD 综合）：报告是该 feature 文件夹的首个产物；每个 `Strong`/`Worth exploring` 候选（**含 Top recommendation**）直接从报告卡片摘录为 `needs-info` 的轻量 `prd` 草稿，Implementation/Testing Decisions 留空。Top + 与其紧耦合的候选合成 scan 文件夹里的一个草稿，独立候选各自 feature 文件夹；草稿留待后续 grill 完善，是否继续走 SDD 由 `/route` 决定。

## 模型调用（Model-invoked）

- **[diagnose-bug](./diagnose-bug/SKILL.md)** —— 顽固 bug 与性能回归的纪律化诊断循环：构建反馈循环 → 复现最小化 → 假设 → 插桩锁定根因，交付确认的诊断本身（根因 + 证据 + 最小复现 + 修复方向建议）——不修复、不自动接力 SDD；是否转 tracked fix 走 `/route`。upstream `diagnosing-bugs` 的 zy/ 改造版：保留其 Phase 1-4 诊断纪律，把 Phase 5-6（直接修复+事后）替换为交付诊断。
- **[to-prd](./to-prd/SKILL.md)** —— 把当前对话综合成父项 issue 并发布到 issue 追踪器 —— 不做访谈，只做综合。按输入性质选模板：feature → `prd`、bug → `bug`、架构深化 → `prd`（用 codebase-design 词汇，`Deepening Goals` 取代 `User Stories`）。upstream `to-prd` 的模型调用改造版（setup 指向 `/setup-skills`），以便被 SDD flow 编排；在本 fork 扩展出 bug 与架构两套模板（见 `references/`）。**发布前由单个 fresh-context sub-agent 做对抗式审查**：先核验真实性（codebase/ADR/glossary 事实陈述是否属实、防幻觉），再判可行性（方向可建、seam 真实、不违 ADR）；3 轮不过则熔断、带草稿交人审。产出供 `/to-spec` 拆解的父项。
- **[to-spec](./to-spec/SKILL.md)** —— 把一个 PRD、一个 bug、当前（已 grilled 的）对话、或一条简单完整需求**翻译并拆解**成 `spec` —— 原子的、**规划完备**的单元，agent 在一次 `/tdd` 会话里实现。简单完整需求走入口完整性门（completeness-bar）校验，不过门退回 `/grill-me` / `/to-prd`，绝不带猜测拆解；过门需求的行为编号为 `AC-1-NN`（全 P0）进入同一翻译。先做**双锚对齐**：把每条 AC 翻译成 `contracts.md` 契约点（`C-NN`，数字与 AC 严格互校）并为每个 P0 AC 播种 `trace.md` 场景行（`S-NN`），然后拆分方案走 best-of-N + judge（判据含锚点完整性）；spec 设计基于 `/codebase-design`，复杂到值得时才启用 DESIGN-IT-TWICE，契约只引用不复制定义。拆分定案后先把 spec 骨架落库（`needs-design`），再逐个设计填充，设计完置 `ready-for-human`（等人审 = Gate A）。替代 upstream `to-issues` 并吸收 upstream `tdd` 的 Planning 步骤。以 `/to-prd` 产出的 `prd`（或一个 bug、一次 grilled 对话、或过门的简单完整需求）作为输入。位于 `/grill-with-docs`/`/to-prd` 与 `/tdd` 之间。
- **[tdd](./tdd/SKILL.md)** —— **场景驱动**实现一个规划完备的 spec。测试不是实现者自造的：从 `trace.md` 取本 spec 拥有的 P0 场景（需求侧产物），逐个「物化为真实 e2e/接口级测试 → 跑红 → tracer bullet 打穿至绿 → 重构」垂直推进；断言的数字与错误码以 `contracts.md` 为准，不许为凑绿放水。切片内单测自由裁量（排障/护边），不是纪律。收尾免逐条人确认：状态翻 `implemented` + evidence comment + 回填 `trace.md` + 提交，由 `/review` 与追溯门禁兜底；卡红回退 spec 的 Rework on failure，发现契约本身错误则上报走 `/spec-sync`。完全替代 upstream `tdd`（planning 已移到 `/to-spec`）。位于 `/to-spec` 之后。
- **[review](./review/SKILL.md)** —— 自某个固定点（commit、branch、tag 或 merge-base）对 `HEAD` 之后的 diff 做双轴复核：**Standards**（代码是否遵循仓库文档化的编码规范）与 **Spec**（代码是否忠实实现原始 issue/PRD/spec —— 以 feature 文件夹的 `contracts.md` 与 `trace.md` 为接口与覆盖真源，核对错误码/字段/数字及 P0 行回填）。两轴各跑一个 fresh-context `general-purpose` 子代理（互不污染上下文，也看不到产出 diff 的对话），再并排聚合报告，**绝不跨轴合并/重排** —— 一轴通过不能掩盖另一轴失败。`/sdd-flow` 在 Stage 3 调用它（固定点 = Gate A 的 spec 提交，即 build 阶段起点之前），也可被 `/route` 或用户直接触发来复核分支/PR/WIP 改动；v1.0.2 起插件提交门禁拦截 agent 的 `git commit` 后也由它复核（固定点 `HEAD`、diff `git diff HEAD`），两轴无硬性违规才写放行标记。需要 `/setup-skills` 已配置 issue tracker。
- **[spec-sync](./spec-sync/SKILL.md)** —— **变更联动**（稳态下使用率最高的 SDD skill）：需求或契约改动时，先锚定移动的 AC/契约点（`C-NN`），再列出全部需联动的下游（PRD 行、contracts、场景、spec、已物化测试、trace 行）交人确认，一并更新后对变更行重跑双锚互校；最后报告哪些 spec 需要重设计/重实现。改动太泛锚不定 → 转 `/idea-to-prd`。位于 feature 已拆解之后的任意时点。
- **[spec-check](./spec-check/SKILL.md)** —— **四维质检 + 状态看板**：fresh-context 子代理对 feature（或整个 tracker）做只读审计 —— 完整性（P0 AC 全有场景/契约/spec）、一致性（AC↔契约数字一致、无内联复制定义）、追溯性（P0 行 done、implemented 有 evidence、标签单向生命周期）、分层纯度（PRD 无技术细节、contracts 无叙事）；P0/P1 分级报告 + 每 feature 一行看板。`/sdd-flow` Stage 3 与人审卡片的机器兜底。
- **[codemap](./codemap/SKILL.md)** —— 生成、更新或 drift-check agent 可读的 CodeMaps：渐进式代码地形索引，能把 agent 引到带源码链接的证据，而不必加载整个仓库。项目级（广度优先）或特性级（深度优先）地图，位于 `docs/codemap/`。喂给 `/to-spec` 的 "reduce chaos" 步骤，以及任何需要先看地形的 skill。改编自 `sdd-riper`。
- **[idea-to-prd](./idea-to-prd/SKILL.md)** —— SDD 流水线前半段：从想法/需求出发，grill 对齐设计（用模型调用的 `/grilling` + `/domain-modeling` 核心，非用户调用的 `/grill-with-docs`）→ `/to-prd` 综合 PRD → 人审 Gate 0（**一屏卡片**：P0 AC 清单 + 范围外 + 关键取舍 + PRD 文件指针，深读可选），止于磁盘上已批准的 PRD；是否接力 `/sdd-flow` 走后续由用户经 `/route` 决定，不做自动交接。只拥有 grill + PRD + Gate 0，**不碰 git**（grill/PRD 产物留在工作树未提交、无分支）。模型调用。
- **[sdd-flow](./sdd-flow/SKILL.md)** —— SDD 流水线后半段：从已批准的 PRD 到交付。入口把 PRD 翻转为 `ready-for-agent`（承接已批准的 PRD——`/idea-to-prd` Gate 0 之后——或手写 PRD）；然后 `/to-spec` 对齐拆解（contracts + trace + specs）→ **Gate A 对齐卡**（切分列表 + P0 AC↔契约对照 + 机器评审结论 + 建议抽查的最高风险 spec，必审一个、其余信任机器）→ `/tdd` 逐 spec 场景驱动实现 → `/review` + **追溯门禁**（全 P0 场景绿、trace 行完整）→ 维护文档收尾（implemented → closed）。spec 质量归 `/to-spec`，不归本 skill。模型调用。

- **[handoff](./handoff/SKILL.md)** —— 把当前对话压缩成 OS 临时目录的 handoff 文件，并输出一条可直接粘贴的下个会话启动 prompt（「请阅读文件 <path> 然后继续 <action>」）。upstream `handoff` 的模型调用改造版（不再 user-only），并新增 emit starter prompt 一步。
