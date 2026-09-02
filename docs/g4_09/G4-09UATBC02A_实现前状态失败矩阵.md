# G4-09UATBC02A 实现前状态失败矩阵

Status: implementation preflight

START_HEAD: `6a50a2c04a244888c58e4eb395226b72539b5364`

Governance HEAD: `d6d8b54530194488c775bcdc601fdd1f965b4230`

## 1. Authority resolution

`G4-09UATB_OWNER_FINDING_STREAMING_PROTOCOL_ROBUSTNESS.md` 记录了 Owner 现场与早期诊断，其中继续放宽混合 framing 的方向已被随后冻结的 model-freedom amendment 和正式 BC02A packet supersede。本轮删除 `control JSON + narrative body` 混合协议，不继续积累 framing 特例。

## 2. 职责与层级

| 职责 | 层级 | 理由 |
|---|---|---|
| control object 的 exact 字段、proposal 与 Program 结果不变量 | L0 公理层 | 属于稳定 mechanics truth，不涉及 I/O 或流程 |
| isolated control response 的 JSON 解析与语义校验 | L1 器件层 | 单一可复用解析器，只依赖 L0 |
| control/recovery/narrative 编排、持久化顺序、重试与降级 | L2 流程层 | 拥有完整 action use case 与失败窗口 |
| UI-neutral Host 返回状态与 timing 契约 | L3 外交层 | 向 UI 暴露稳定、非秘密结果，不泄露内部状态器 |

跨模块依赖继续只经过现有 `首次开场/L3`、`context/L3`、`provider/L3` 与 Session Runtime 公开 seam；不修改受保护模块。

## 3. State matrix

| 起始 durable 状态 | Control 结果 | 下一状态 | Provider calls | Durable mechanics |
|---|---|---|---:|---|
| 无 resolution | valid NO_CHECK | free-form NO_CHECK narrative | 2 | narrative completion 后冻结 exact NO_CHECK resolution；无 check |
| 无 resolution | valid CHECK_REQUIRED | Program roll + durable check，再 free-form result narrative | 2 | narrative 前已有 exact check |
| 无 resolution | malformed control | bounded control recovery | 2 calls 已启动 | 暂无 mechanics write |
| 无 resolution | recovery valid NO_CHECK | free-form NO_CHECK narrative | 3 | 同 normal NO_CHECK |
| 无 resolution | recovery valid CHECK_REQUIRED | durable check，再 result narrative | 3 | 同 normal CHECK_REQUIRED |
| 无 resolution | recovery 仍 malformed | free-form degraded narrative | 3 | 无 check、无 NO_CHECK marker |
| existing unaccepted check | 不再 control | exact result narrative replay | 1 | 复用原 check，不 reroll |
| existing unaccepted NO_CHECK | 不再 Provider | exact frozen narrative replay | 0 | 复用原 resolution |
| existing accepted resolution | 不再 Provider | already_accepted | 0 | 不新增 Turn/marker |

## 4. Failure matrix

| 窗口 | 结果 | Conversation | Durable mechanics | Retry |
|---|---|---|---|---|
| control malformed，首次 | 自动 recovery，不发布终态 | 无 provisional Turn | 无写入 | 内部且仅一次 |
| control malformed，第二次 | fail-soft narrative；返回稳定 `control_unresolved` degradation flag | narrative delta 可见但 provisional | 无 check/NO_CHECK marker | 不再 control retry |
| control credential/transport/service failure | terminal failure | 无 accepted Turn | 无新增 mechanics | stable action 可由 UI 重试 |
| narrative failure/cancel | terminal failure | partial draft failed/cancelled，不进 Context | CHECK 分支保留既有 durable check；其它分支无新增 mechanics | 同一 provisional Turn 可复用；CHECK 不 reroll |
| NO_CHECK narrative completed，冻结 resolution 失败 | hard persistence failure | 不接受 | 无假 marker | stable action 可重试 |
| resolution 已冻结，Conversation accept 失败 | hard persistence failure | 不接受 | exact NO_CHECK/check 可 replay | retry 不重新分类或 reroll |
| Conversation durable，acceptance marker lost ACK | reopen recovery | exact accepted Turn | 补发 exact marker | 不新增 Provider/Turn |
| narrative Provider completion 但正文空白 | `empty_generation` | 不接受 | CHECK 可保留；NO_CHECK/degraded 不造 marker | 可安全重试 |

## 5. Invariants

- Narrative lane 不含 JSON、sentinel、首行或物理 LF 契约。
- Control lane 最多 initial + one recovery；不存在循环或通用 retry framework。
- Selected Provider only；无跨 Provider fallback。
- Player-visible delta 只进入 provisional Conversation memory；无 per-token canonical write。
- CHECK_REQUIRED 的 durable check 严格先于 result narrative request。
- Degraded success 返回 `status=accepted` 供现有 UI 正常解锁，同时携带非秘密 degradation flag；不伪造成功 adjudication truth。
- SQLite schema v4、Source、Final Create、Game Library、Runtime Settings 与 Provider seam 保持不变。
