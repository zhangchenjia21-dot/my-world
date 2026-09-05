# G5 Combined Owner UAT Checkpoint

Status: **READY FOR OWNER UAT**  
Phase: **G5 World Semantics & GM Runtime**  
Purpose: one real-play checkpoint before the final G5-GATE verdict.

## 1. Test principle

Use one fresh Three Kingdoms Game where practical. Judge the actual player experience, not prompt text or internal debug state. The goal is to verify that the already-engineered G5 capabilities compose into a coherent RPG experience.

This is not another engineering implementation task. Record concrete visible failures; only then route the owning Work Item/capability revision.

## 2. Required observations

### A. Living-world independence

Play several ordinary turns, including at least one low-impact turn.

Confirm:

- the world can remain quiet when nothing meaningful should advance;
- at other times, NPC/world developments may advance without pretending the Player caused everything;
- independent developments feel relevant rather than constant noise.

### B. NPC agency + knowledge boundary

Create or encounter a situation where an NPC can plausibly know/do something outside the Player's direct control.

Confirm:

- NPCs feel capable of independent action;
- private NPC/world information does not appear in the player-safe side panel merely because Runtime/GM knows it;
- once the protagonist genuinely learns related information through play, the side panel may show it.

### C. Meaningful risky action / Public d20

Take one clearly risky, meaningful action that should reasonably call for a check.

Confirm:

- a visible Public d20 appears when appropriate;
- ordinary/no-risk actions can still remain NO_CHECK;
- the mechanical result is followed by natural free-form GM Narrative rather than a hardcoded effect table;
- the consequence matters later in the world and is not forgotten immediately;
- mechanics do not dominate every action.

### D. Save / reopen / Restore

After meaningful world/mechanics/knowledge changes:

1. create a Save;
2. continue long enough for additional state to change;
3. close/reopen and verify the current reality remains coherent;
4. Restore to the earlier Save and verify restored-away knowledge/world consequences no longer influence the current experience.

Judge coherence, not whether historical database rows were physically deleted.

### E. Player agency boundary

Across the run, confirm the GM freely advances world/NPC/scenes and natural consequences but does not silently make new meaningful protagonist decisions that the Player did not express or clearly imply.

Small connective behavior is acceptable; meaningful protagonist choices remain with the Player.

### F. Player-safe side panels

Confirm the current side panels are useful rather than debug-like:

- Player/World identity is understandable;
- known facts are useful and bounded;
- no internal IDs/hashes/instructions/omniscient secrets appear;
- Restore/reopen behavior feels correct.

### G. Three Kingdoms prose — MW-005 R4

Judge several GM responses, not only the Opening.

Confirm whether the prose is now perceptibly closer to the intended Three Kingdoms voice through:

- sentence rhythm and narrative distance;
- forms of address, etiquette and social register;
- character dialogue style;
- military/political information arriving through scene, people, messengers, reports, documents or period-appropriate exchange rather than modern strategic briefing;
- sustained style across the whole response rather than only antique nouns.

Also confirm it remains readable and does **not** mechanically force chapter-novel clichés, pseudo-classical phrasing, poetry, or future-canon leakage.

### H. Presentation / visual comfort

Confirm:

- Markdown-lite bold/italic/separators render naturally without exposing markup noise;
- the overall visual comfort pass remains acceptable during extended reading.

## 3. Owner verdict format

A compact verdict is sufficient. Report each item as:

```text
A Living-world independence: PASS / FAIL + one sentence
B NPC agency / knowledge: PASS / FAIL + one sentence
C d20 mechanics integration: PASS / FAIL + one sentence
D Save/reopen/Restore: PASS / FAIL + one sentence
E Player agency boundary: PASS / FAIL + one sentence
F Side panels: PASS / FAIL + one sentence
G Three Kingdoms prose: PASS / FAIL + one sentence
H Presentation / visual comfort: PASS / FAIL + one sentence
Overall G5 product feel: PASS / FAIL + key blocker if any
```

A FAIL should describe a reproducible visible product defect. Do not propose implementation architecture in the verdict; GPT will route the defect to the correct Work Item lineage.

## 4. Gate rule

If no blocking product defect remains and the composed experience satisfies the G5 product intent, Owner may issue **G5-GATE PASS**.

If a blocker is found, G5-GATE remains open and the defect is routed to its owning existing Work Item revision when it is the same outcome, or to a new flat Work Item only for a genuinely distinct outcome.
