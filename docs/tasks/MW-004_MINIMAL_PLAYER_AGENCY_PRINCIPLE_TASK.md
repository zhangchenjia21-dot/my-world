# TASK｜MW-004｜Minimal Player Agency Principle

Type: product semantics / minimal prompt behavior  
Implementer: GPT — explicit Owner delegation for this tiny bounded change  
Independent Reviewer: not self-assigned  
Capability-Anchor: **G2 AI Conversation Spine**  
Inserted-By: **Owner**  
Triggered-By: G5-04 Owner UAT observation of GM ending a still-open player interaction  
Revision: **1**  
Base: `my-world/main@b9ea5cb3ebe9e91c9c2ab1f4a93daf30b440767d`  
Governance Base: `Vibe-Coding/main@f5f677c7c0eb5df4cd5c0a99834dccb4d496b01e`  
Status: **IMPLEMENTED — OWNER UAT**

## 1. Primary outcome

Protect one minimal authority boundary without constraining free-form GM Narrative:

> **The GM owns the freedom to advance the world; the Player owns new meaningful choices for the protagonist.**

The model may freely advance world/NPC/scene response, consequences of already expressed player action, and small connective behavior that is not itself a choice. If narration would create a new meaningful protagonist choice that the Player did not express and the current intent does not clearly imply, leave that choice to the Player.

## 2. Light mode clarification

Only one clarification is added:

> `Light` does not expand the GM's authority to make meaningful protagonist choices for the Player; it only permits more natural completion of non-decisional connective detail.

Do not define or redesign Full/Narrative in this task.

## 3. Required implementation shape

Use the smallest existing seam: the shared GM system instructions in `src/context/上下文组装器.gd`.

This task must **not** add:

- parser/classifier for player-agency violations;
- Narrative rejection/finalize barrier;
- retry/regeneration enforcement;
- keyword blacklist;
- forced questions or stop points;
- fixed response format;
- new Provider protocol;
- control-mode platform redesign;
- G5-04 mechanism changes.

## 4. Focused proof

`tests/mw004/最小玩家主权原则测试.gd` should verify:

- the general Player Agency principle is present;
- the Light clarification is present;
- existing Narrative freedom/richness instructions remain present;
- ordinary Light continuation still uses the normal system + user message shape with no extra protocol/gate.

This assistant environment does not have Godot, so GPT must not claim the focused test was independently executed here.

## 5. Owner UAT

Use the real `run-game.cmd` path and continue an interaction where the protagonist still has an obvious meaningful choice available.

PASS signal:

- GM freely writes NPC/world/scene response;
- GM may add tiny connective actions;
- GM does not decide to leave, agree, refuse, reveal, commit, abandon, or otherwise create a new meaningful protagonist choice without the Player expressing or clearly implying it;
- prose does not become timid, mechanical, or repeatedly ask for permission.

If this behavior feels natural, continue the existing G5-04 UAT. Do not broaden MW-004 merely because other control-mode semantics could theoretically be specified later.
