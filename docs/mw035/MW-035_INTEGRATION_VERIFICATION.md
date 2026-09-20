# MW-035 Integration Verification

Status: **REVIEWED INTEGRATION COMPLETE**

## Reviewed lineage

- Formal Code Base: `0066b587f1d756b55ee18abfa5f473e78a3aeea2`
- Task Packet / Starting HEAD: `120062661ad419d52c36fc339cee6f226b09a78d`
- Implementation HEAD: `cc530f2844e51dc7a071c80f857f206f9dea0673`
- Codex Candidate: `d8b19d39bef075b9d69a76a0e9532212b021c99a`
- Independent Review IR1: `22e0061f87bab00dc8ec22be6d5312d584c80c48`
- Engineering verdict: **PASS_WITH_NOTES**

## Integration

Pre-integration freshness confirmed implementation `main` remained at the exact Formal Code Base and the task branch remained at the reviewed tip.

`main` was advanced to the reviewed MW-035 lineage with a **non-force fast-forward**. No merge commit, force push, history rewrite, or unreviewed production mutation was introduced.

This record is the only post-review integration addition.

## Integrated production outcome

Public d20 `control` / `control_recovery` now use the existing Context structural selector and validated runtime model capacity.

The mechanics working set is structurally:

- P0: control contract + active Player action + exact Expansion rules + minimum Game/World identity/instructions;
- P1: latest/remaining accepted Conversation + current Character + current World/Knowledge/Agency/Evolution + factual Inventory + Public mechanics;
- P2: frozen Opening/Entry/T0 World/Player/NPC source background;
- literary style excluded from control.

Narrative d20 stages remain on the MW-033 Narrative working-set path.

## Acceptance evidence

- MW-035 focused: `324 / 324`, real Provider calls `0`.
- MW-033 focused: `206 / 206`.
- MW-034 focused: `441 / 441`.
- relevant regressions: `49 / 49`.
- 256k control: `200198 / 209715` bytes.
- 256k control recovery: `200267 / 209715` bytes.
- 1m control: `655604 / 838860` bytes.
- 1m control recovery: `655673 / 838860` bytes.
- P0 overflow: zero Provider start, zero RNG, zero durable mechanics mutation.
- Restore / Regenerate / reopen currentness: PASS.
- CHECK / NO_CHECK / degraded lifecycle: PASS.
- Godot 4.7.2 final import: PASS.
- fresh Windows export / `ValidateExportOnly`: PASS.

## Notes

- Live-model adjudication quality remains for Product validation; Engineering evidence used zero real Provider calls.
- Current World quality is bounded by the existing canonical World-turn Context owner; MW-035 does not redefine that owner.
- Large optional P2 may remain omitted even at 1m by structural budget.
- existing bounded teardown warnings remain unchanged and nonblocking.

## Product status

No Product PASS is claimed. No Package-8 completion is claimed by this integration record.

Ownership returns to GPT for the Package-8 closure evidence gate and to determine whether the accumulated G6+G7 risk boundary is now ready for the planned concentrated Owner Product test.
