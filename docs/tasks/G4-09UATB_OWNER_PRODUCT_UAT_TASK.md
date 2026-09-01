# G4-09UATB — Owner Product UAT B

Status: **HOLD — OWNER-REQUESTED MODEL SETTINGS PREREQUISITE**  
Parent: **G4-09 First Playable B: Add Real Expansion**  
Product owner: **Owner**  
Semantic/review owner: **GPT**

Accepted prep review:

`docs/g4_09/G4-09P1_INDEPENDENT_REVIEW.md`

Owner-requested prerequisite:

`G4-09R1 Runtime Model Settings v0.1`

Canonical decision:

`Vibe-Coding/my world/architecture/foundation/G4_RUNTIME_MODEL_SETTINGS_V0_1_DECISION.md`

## Hold reason

Before beginning the real Product UAT, the Owner explicitly requested application-level runtime selection for:

```text
Model: DeepSeek V4 Pro / DeepSeek V4 Flash / Kimi K3 / Kimi K2.7
Context: 256K / 1M
Reasoning: Low / Medium / High / Max where the selected model supports graded effort
```

The previous DeepSeek-only UAT instructions are therefore stale until G4-09R1 backend + UI integration passes Independent Review and Owner export/real-provider freshness is revalidated.

Do not execute this UAT against the old DeepSeek-only settings surface and do not return a product verdict yet.

## Resume condition

```text
G4-09R1M1 backend — GPT IR PASS
→ G4-09R1B1 UI — GPT IR PASS
→ real DeepSeek + Kimi integration/freshness as required
→ refreshed Owner UAT instructions
→ G4-09UATB ACTIVE — OWNER
```

When resumed, the UAT still judges whether `判定与检定：公开 d20` adds worthwhile gameplay, but it will run through the newly accepted runtime model settings path.

G4-09, G4-08 and G4-GATE remain open.