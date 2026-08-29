# 汉末三国：天下未定｜可选拓展、能力语义与本局持久事实

## World 可以独立运行，但不独占所有玩法语义

本 World 足以支撑以叙事、社会关系和常识因果为主的完整游戏；更深的政争、财政、战争、能力成长、身体、生存、关系或穿越玩法可以由对应 Expansion / Runtime Domain 加深。

原历史资产曾明确区分这些 owner。v0.2-r2 保留这种分工，但不把尚未实现的 Expansion 写成当前硬依赖。

## 专用拓展方向

### 政争与势力

如果启用相关 consumer，它可以在 World 提供的：

- 当前政治格局；
- 官职制度语义；
- 朝廷名义；
- 地理控制；
- 行动者关系；

基础上进一步推演官职任免、势力消长、合法性和外交。

### 财赋与治理

可以在农业、人口、市场、交通、地方社会与控制质量基础上进一步运行财政、赋税、粮食、生产与治理。

### 军略与战争

可以在山川、道路、水系、军队组织和军事生活常识基础上进一步处理编制、补给、行军、士气与战役裁决。

### 历史参照与分歧

如果未来启用，它只能比较外部历史与 Game-local Reality、帮助拥有外部知识的角色理解哪些记忆仍有参考价值。

它不能：

- 把外部历史重新升格为未来事实；
- 写回 World Source；
- 要求现实向 canon 收敛；
- 创建“必须补发生”的替代事件。

## 通用拓展方向

### 人物能力与技艺

World 提供时代能力语义与技术文化边界；Character T0 profile 保存当前人物截至 T0 已经获得的真实能力证据。任何成长都应发生在 Game-local lived history 中。

### 身体状态 / 生存需求

World 提供时代医疗、物质环境、旅行与生活条件。具体伤病、疲劳、治疗、饥饿、睡眠等动态事实由对应 Runtime Domain持有。

### 关系与亲密

World 提供家族、礼法、婚姻和身份背景。具体两个人之间的信任、恩怨、爱情、承诺和边界必须来自 Character / Relationship Domain / lived interaction，而不是 World 预写。

### 穿越与系统

World 提供时代舞台和外部知识失效的因果边界。Character 是否来自现代、知道多少、有没有额外系统能力，应由明确角色/Expansion 内容决定。

## 能力摘要不是人物真相

历史玩家熟悉的若干能力维度可以作为摘要语言，但不能成为强制 Schema 或覆盖具体人物事实。

例如：

- 军事指挥与统率能力；
- 个人体能和兵器技艺；
- 思考、判断与谋略；
- 行政、人事、外交和财政；
- 表达、辩说与人际感召；

这些维度只有在真实人物能力已经形成时才可用于概括。它们不等于官职、爵位、财富、声望、合法性、美貌或别人对其好感。

## Source 不拥有 Game 里的新历史

一局长期运行后，以下变化必须沉淀为该 Game 的 durable truth：

- 战争与政治结果；
- 人物生死与继承；
- 边界、城市控制与道路变化；
- 官职、生涯和组织变化；
- 伤病及后遗症；
- 能力与技艺真实成长；
- 关系、共同经历、恩怨、信任与亏欠；
- 城市破坏与重建；
- 市场、人口与迁徙变化；
- 消息传播、秘密泄露和错误认知的修正；
- Game-local 新形成的长期人物语义。

这些事实必须被后续场景持续尊重。

## Game-local semantic evolution

Source Schema 不是 Living World 的可能性上限。

如果一局历史真的创造了 Source 没有预设的新意义，例如：

- 某人物形成新的政治伦理；
- 某组织发展出新的制度传统；
- 某种长期创伤改变人物判断；
- 新宗派、学说、盟约、身份或地方文化形成；

Game-local semantic object 可以扩展这些意义，但必须：

- 不修改 reusable Source；
- 不破坏 Program-owned identity / durability；
- 不重复已有 Domain 的 canonical fact；
- 进入 Timeline / Save / Restore，可随玩家回档而恢复。

## Source 永不被单局污染

下一局 New Game 应从同一个 exact immutable Source generation重新 materialize selected T0，而不是继承上一局战争、死亡、人格变化或玩家建立的新制度。

> **Source remembers the authored world; each Game remembers what actually happened there.**