# G4-07 First Playable A — Owner UAT

Status: **READY FOR OWNER UAT**
Owner: **Owner / User**
Engineering reviewer: GPT
UAT implementation base: `2f45614baa0a3c38dac3439934122084817d4602`
G4-07B Independent Review record: `docs/g4_07b/G4-07B_INDEPENDENT_REVIEW.md`

> Engineering has proved the vertical works. This UAT decides whether it is actually a worthwhile AI RPG experience.

## 1. What to judge

Do **not** judge code, IDs, schemas, fingerprints, or test reports. Judge the product you see and play.

Primary questions:

1. Does the first scene feel like an actual RPG opening rather than a setup summary or chatbot greeting?
2. Does the World feel specific and information-rich rather than generic?
3. Does the Player Character feel like the selected Character rather than a generic protagonist?
4. Do Guaranteed NPCs remain distinct people instead of being unnaturally pulled into the first scene merely because they were selected?
5. Can you take a free-form action and get a response that clearly continues from what already happened?
6. After Save / Main Menu / Continue, does it feel like the same ongoing Game with no second "first scene" and no lost context?
7. Do Han and Afterglow feel materially different in tone, assumptions, people, and world logic?
8. Does the interface get out of the way enough that the experience feels like playing, not operating an engineering demo?

## 2. Required UAT route A — Han

Use the normal product UI.

Recommended pressure-test composition:

```text
World: 汉末三国：天下未定
Entry: 208 / 赤壁前夕
Player Character: 刘备
Guaranteed NPC: 孙权
Expansion: none
Opening supplement: 从江夏的雨夜开始；不要为了“保证加入”而强制孙权出现在第一幕。
```

Then:

```text
Review
→ Create Game
→ watch the complete GM Opening
→ take at least 3 free-form actions
→ create one Save
→ return to Main Menu
→ Continue
→ take at least 1 more action
```

While playing, watch specifically for:

- later canon/future knowledge leaking into the 208 start;
- the model treating historical future events as fixed destiny;
- Liu Bei sounding generic or interchangeable;
- Sun Quan being forced into the opening without scene causality;
- responses forgetting the Opening or your immediately preceding actions;
- Continue producing a second Opening or losing the durable conversation.

## 3. Required UAT route B — Afterglow

Create a separate Game through the same normal UI.

Recommended composition:

```text
World: 诸界余辉：埃瑟维亚
Entry: 1287 / 公共工程余波
Player Character: 莉维娅·塞兰
Guaranteed NPCs: 阿德里安·维尔克、杜恩·石痕
Expansion: none
Opening supplement: 从奥维斯塔公共工程余波开始；保留每个人的信息边界，不要为了介绍角色而把所有人拉到同一场景。
```

Play at least 3 free-form actions.

Judge whether this Game feels structurally and narratively different from Han, not merely renamed.

## 4. Short no-Entry check

Create one additional Game with a World + Player Character but choose **不指定开局**.

You only need to observe the Opening and make 1 action.

Question:

> Does no-Entry feel intentionally open-ended but still playable, or does it feel starved/confused enough that the product contract should change?

Do not change the contract during UAT; just record the observation.

## 5. PASS / FAIL guidance

### Product PASS candidate

PASS is appropriate if all of these are true:

- the complete New Game → Opening → free play → Save → Continue route feels coherent;
- both World families feel distinct;
- Character identity is noticeable in actual play;
- narrative has enough concrete world/character material to feel authored rather than generic;
- Guaranteed NPC selection does not systematically collapse everyone into scene one;
- immediate continuity is reliable;
- no serious temporal/future leakage is observed in the Han early start;
- UI states are understandable without engineering knowledge;
- no issue makes you unwilling to keep playing the same Game.

### Product correction required

Do not PASS if you observe a material problem such as:

- generic prose despite rich Source material;
- selected Characters converging into the same voice/personality;
- future/canon leakage that constrains the living Game;
- guaranteed cast systematically forced into the opening;
- Context starvation or obvious forgetting within only a few turns;
- Save/Continue breaking narrative continuity;
- duplicate first Opening / duplicate Game creation;
- UI state confusion that materially interrupts play.

## 6. Minimal Owner return

After playing, you do not need to write a formal report. Return these six items to GPT:

```text
1. Han：PASS / 有问题
2. Afterglow：PASS / 有问题
3. no-Entry：可玩 / 太空 / 其他
4. 最明显的优点：一句话
5. 最影响继续玩的缺点：一句话（没有就写“无”）
6. 总体：我愿意继续玩 / 还不像成品 / 需要先修某问题
```

GPT will translate that UAT evidence into Product PASS or the smallest forward correction task.

## 7. Gate rule

Engineering PASS does not close G4-07.

Only after Owner UAT can GPT decide:

```text
G4-07 PASS / CLOSED
or
G4-07 Product Correction ACTIVE
```

Do not start G4-08 Expansion before this decision.
