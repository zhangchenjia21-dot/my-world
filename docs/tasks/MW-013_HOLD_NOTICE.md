# HOLD NOTICE｜MW-013｜Internal Declarative UI Host v0.1

Status: **HOLD / NOT AUTHORIZED TO IMPLEMENT YET**  
Work Item: **MW-013**  
Date: **2026-09-06**  
Reason: **G6 route-order correction after Owner review of the canonical roadmap**

## 1. Immediate instruction

If Codex has already received `docs/tasks/MW-013_INTERNAL_DECLARATIVE_UI_HOST_V0_1_TASK.md`, **STOP before further code-changing work**.

Do not implement or continue MW-013 until GPT/Owner explicitly re-authorizes it after the preceding grounded G6 surface work.

If any local work has already started:

- do not merge or push to `main`;
- do not discard unknown work;
- report current branch / worktree / HEAD / `git status --short`;
- keep any branch/worktree isolated until GPT decides whether to preserve or abandon it.

## 2. Why the route is corrected

The canonical G6 roadmap order is:

```text
Runtime projection → ViewModel → real UI consumer
→ re-audit + Runtime Asset Resolution only when a real visual consumer requires it
→ portrait / scene / authored-map presentation when grounded
→ Character / Relationship / Inventory / Faction / Map / Save real Surfaces
→ Expansion mechanic-state consumer
→ Internal Declarative UI Host v0.1
→ bounded Action Intent
→ responsive / Theme / navigation
→ Owner UAT / visual polish
```

MW-011 completed the first real consumer vertical. Visual Runtime was audited and intentionally deferred because no mature authored visual demand exists.

That deferral does **not** authorize jumping directly over the real-surface and Expansion-consumer steps into Declarative UI Host infrastructure.

## 3. Disposition

`MW-013` remains a valid future Work Item concept, but its implementation timing is deferred.

The next action is GPT product/architecture work to ground the right-side information architecture and choose the next real G6 Surface from actual domain owners. No empty tabs or fake RPG state may be created merely to satisfy roadmap order.

Until explicit re-authorization:

**MW-013 = HOLD / DO NOT EXECUTE.**
