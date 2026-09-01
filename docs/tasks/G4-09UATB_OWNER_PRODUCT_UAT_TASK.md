# G4-09UATB — Owner Product UAT B

Status: **ACTIVE — OWNER**  
Parent: **G4-09 First Playable B: Add Real Expansion**  
Product owner: **Owner**  
Semantic/review owner: **GPT**

Accepted prep review:

`docs/g4_09/G4-09P1_INDEPENDENT_REVIEW.md`

Product instructions:

`docs/g4_09/G4-09UATB_Owner产品验收说明.md`

## Purpose

Judge one product question through the real shipped path:

> Does `判定与检定：公开 d20` add worthwhile gameplay rather than merely adding technical state?

## Required route

Launch only through `run-game.cmd` and create a new Game using:

```text
World      汉末三国：天下未定
Entry      208 / 赤壁前夕
Player     刘备
NPC        孙权 (optional guaranteed)
Expansion  判定与检定：公开 d20
```

Verify:

1. Review visibly lists the Expansion.
2. Real DeepSeek Opening completes.
3. A genuinely risky action with meaningful failure stakes produces a public d20 mechanic card.
4. GM continuation respects the Program-owned success/failure result.
5. An ordinary/no-risk action produces no unnecessary dice card.
6. Save → Main Menu → Continue returns to the same Game with the same history and mechanic result.
7. The mechanic improves play in tension, clarity or meaningful choice.

## Verdict

Return only:

```text
PASS
```

or:

```text
FAIL
<what felt wrong / what broke>
```

Engineering evidence does not substitute for this verdict.

## Progression

If Owner PASS:

```text
G4-09 First Playable B      PASS / CLOSED
G4-08 Expansion Pack v0.1   Product PASS / CLOSED
→ Decision Propagation
→ G4-10 Runtime Asset Resolution
```

If Owner FAIL, GPT classifies the concrete product seam and routes the smallest correction. G4-GATE remains NOT YET either way until remaining G4 work completes.
