# Cart Map

## Game chain (shootinator.p8 → … → shootinator.p8)

**`shootinator.p8`** — entry point: title screen + story dialogs
- chains → `gameplay_1.p8`

**`gameplay_1.p8`** — levels 1 + 2
- includes: `spawn_tab_compact.lua`, `levels.lua`, `player.lua`, `mob.lua`, `utils.lua`, `enemies.lua`, `textbox.lua`
- chains → `gameplay_2.p8`

**`gameplay_2.p8`** — level 3 flight
- includes: `spawn_l3.lua`, `levels.lua`, `player.lua`, `mob.lua`, `utils.lua`, `enemies.lua`, `textbox.lua`, `boss.lua`
- chains → *(missing: `load("boss.p8")` not yet written)*

**`boss.p8`** — boss fight *(cart does not exist yet)*
- should chain → `shootinator.p8`

---

## Dev cart (enemytest.p8)

**`enemytest.p8`** — active dev/experimentation cart
- includes: `utils.lua`, `player.lua`, `mob.lua`, `enemies.lua`
- no load() chain (standalone)
- commented-out: `reload(0,0,0x42ff,"gameplay_1.p8")`, `#include levels.lua`
- spawn data defined inline in the cart (not via a separate lua file)

---

## Orphaned files

- `level_intros.lua` — never included anywhere
