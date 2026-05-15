# Shootinator - Project Context

## What this is
A Pico-8 shoot-em-up. Multi-cart structure (see below).

## File map

### Gameplay cart 1 — `shootinator.p8` (levels 1 + 2)
Lua includes:
- `mob.lua` — base mob creation and default behaviours
- `player.lua` — player, shield, powerup creation
- `enemies.lua` — all enemy types (disc, flap, blob, green, lazer, static, spinshot, etc.)
- `utils.lua` — shared utilities (spline reading, easing, etc.)
- `levels.lua` — compact level loader (~17 lines). Reads `spawn_dat` string, builds `spawn_tab`.
- `spawn_tab_compact.lua` — canonical level data. Two levels separated by `|`. Format: `offset,class,func,params...` with relative distances.
- `textbox.lua` — dialog/textbox rendering
- `level_intros.lua` — level intro logic (currently stub)

### Gameplay cart 2 — `gameplay_2.p8` (level 3 + boss)
Same engine includes as above, plus:
- `boss.lua` — boss-only enemies: `add_enemy`, `mine`, `boss`, `boss_attach`, `line_shot`
- `spawn_l3.lua` — level 3 spawn data (boss at distance 400, expand as needed)

### Dev/test carts (do not merge into game carts)
- `enemytest.p8` — enemy test cart (contains reference boss code at commit `dbc0c08`)
- `enemytest2.p8` — older enemy test (December 2023, do not use for boss reference)
- Various others (`collision-test.p8`, `spline.p8`, etc.)

## Token counts (as of multi-cart split)
Use `info` in Pico-8 on the non-combined cart for accurate counts.
`combine.py` now handles indented `#include` — editor count on combined file should match.

- **shootinator.p8**: 6936 / 8192 tokens (~1256 free)
- **gameplay_2.p8**: 8171 / 8192 tokens (~21 free), compressed 14784 / 15616

gameplay_1 has room for a new L2 enemy. gameplay_2 is tight — bug fixes only, no new features without stripping something.

## Goals

1. **3 levels** — practical, level data is cheap in compact string format
2. **Boss at the end of level 3** — boss code is in `gameplay_2.p8` via `boss.lua`
3. **Multi-cart** — implemented. `shootinator.p8` → `gameplay_2.p8` via `load()` at end of level 2.
4. **Lines within 32 chars** — general style goal; **exception: boss code is exempt**
5. **Readable code** — general goal; **exception: boss code uses the `_ENV` trick** — intentional.

## Level design status

- **Level 1**: Done. Green, disc, flap enemies. Data in `spawn_tab_compact.lua` (first section).
- **Level 2**: Skeleton only. Lazer turret focus mechanic. Support enemy unspecified/unimplemented. Data in `spawn_tab_compact.lua` (second section, after `|`). **Currently hardcoded as `level=2` in `init_game()` for testing.**
- **Level 3**: Stub — boss spawn only in `spawn_l3.lua`. No intro enemies yet.

## Cart structure (implemented)

- **`shootinator.p8`** (gameplay_1): Levels 1+2. On level 2 complete: saves score/lives/powerups to cartdata slots 1-5, calls `load("gameplay_2.p8")`.
- **`gameplay_2.p8`** (gameplay_2): Level 3 + boss. On init: restores state from cartdata. Win → `init_win()`.
- **`intro.p8`** (not yet built): Planned. Title + level intro dialogs. Would free tokens in gameplay carts by removing title screen code.

### Cartdata slots
- 0: hi-score (existing)
- 1: score
- 2: lives
- 3: spread
- 4: rapid
- 5: str_shield (1 or 0)

## Within-cart level progression (not yet implemented)
Level 1 → level 2 transition within `shootinator.p8` is not coded. Currently `level=2` is hardcoded in `init_game()` for development. A lightweight `init_level()` is needed that resets `d`, rebuilds `spawn_tab`, clears enemies, keeps player state.

## Known boss bugs
- **Arms don't die with the boss** — **FIXED** in `boss.lua`: `boss_attach.upd` checks `boss.hp<=0` and removes itself.
- **Mines were working but in an early state** — needs playtesting to assess.
- Other bugs TBD — rediscover by playing `gameplay_2.p8`.

## Spawn data format
```
offset,class,func,params...
```
- `offset`: distance from previous spawn (relative, accumulates)
- `class`: `en` (enemy, added to enmys) or `pup` (powerup, self-manages)
- `func`: function name (looked up via `_ENV[name]`)
- `params`: passed directly to the function

Levels separated by `|`. The loader in `levels.lua` uses `level` variable to pick the right section.

## Accurate token counting
- Run `info` in Pico-8 on the **non-combined** `.p8` file — this is authoritative.
- `combine.py` now handles indented `#include` (fixed). Combined file editor count should match `info`.
- Do NOT use the editor count on the non-combined file with includes — it undercounts.
