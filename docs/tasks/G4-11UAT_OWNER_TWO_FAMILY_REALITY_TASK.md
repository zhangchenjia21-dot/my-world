# TASK｜G4-11UAT｜Owner Two-Family Reality Test

Type: **Owner Product UAT**  
Owner: **OWNER**  
Reviewer / semantic owner: **GPT**  
Parent: **G4-11 Two Primary Asset Families Reality Test**  
Prerequisite: **G4-11P1 PASS / CLOSED**  
Product verdict ceiling: **PASS / FAIL**

## 1. Product question

Judge one thing:

> Do the actual Han / 刘备 and Afterglow / 莉维娅 play experiences materially feel like two different RPG worlds rather than one generic AI chat with swapped names?

This is a product-value test, not another engineering audit.

## 2. Explicit non-scope

Do not judge:

- portrait / scene / authored-map availability;
- visual polish;
- G6 RPG layout;
- Public d20 value again;
- future G5 NPC agency / faction simulation / event evolution that does not exist yet.

Both comparison Games use `Expansion = none` so the World/Character family is the main variable.

## 3. Fixed comparison

### Family A

```text
World       汉末三国：天下未定
Entry       208｜赤壁前夕
Expansion   none
Player      刘备
Guaranteed NPCs  optional; preferably none for the clean comparison
```

### Family B

```text
World       埃瑟维亚：诸界余辉
Entry       t0-1287-ovista / 奥维斯塔
Expansion   none
Player      莉维娅·塞兰
Guaranteed NPCs  optional; preferably none for the clean comparison
```

Use the currently selected model profile. Do not change model settings solely to make one world look better.

## 4. Short Owner path

Use `run-game.cmd`.

For each family:

1. New Game with the fixed World / Entry / Player above.
2. Leave opening supplement empty unless you personally want a setup detail. The Source itself should carry the world.
3. Let Opening complete.
4. Play naturally for roughly 2–4 actions. Do not use a benchmark script; interact with what the world presents.
5. Save or return to Main Menu after the conversation is durably complete.
6. Create/open the other family and play similarly.
7. Switch back to the first Game and Continue once, confirming it resumes its own reality rather than the other family.

You do not need a long session.

## 5. PASS criteria

Return `PASS` if, from ordinary play, you can reasonably say all of the following:

- Han/刘备 feels grounded in its own historical-political/material reality;
- Afterglow/莉维娅 feels grounded in its own fantasy/social/magical reality;
- the Player Character voice/position/available concerns are materially different between the two;
- neither Game obviously leaks names, concepts or current situation from the other family;
- Save / Main Menu / switching / Continue remains coherent;
- the difference arises naturally from Source + Game Context, not from a visible forced template.

Do not require every model turn to be brilliant. The gate is whether the product clearly sustains two different Source-grounded RPG realities.

## 6. FAIL criteria

Return `FAIL` with the concrete symptom if, for example:

- both worlds rapidly collapse into the same generic assistant/GM voice and concerns despite their Source;
- important World/Character material is absent enough that one family does not establish itself;
- cross-family names/facts leak between Games;
- switching/Continue restores the wrong Game reality;
- one family cannot complete ordinary play through the current production path.

A visual placeholder/absence is not a failure for this UAT.

## 7. Verdict return

Minimum return:

```text
PASS
```

or:

```text
FAIL
<one or two concrete observations>
```

If PASS, GPT may close G4-11, pass G4-GATE, close G4 and shape G5. If FAIL, GPT will correct only the concrete Source/Context/Game seam exposed by the UAT; visual work remains deferred unless the Owner explicitly changes that decision.
