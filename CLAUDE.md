# Shootinator - Project Context

## What this is
A Pico-8 shoot-em-up. Multi-cart structure (see below).

## File map

### Launch cart — `shootinator.p8`
Entry point. Title screen + story dialogs. Loads `gameplay_1.p8` to start the game.
On game over (from any cart): load back here.

### Gameplay cart 1 — `gameplay_1.p8` (levels 1 + 2)
Lua includes:
- `mob.lua` — base mob creation and default behaviours
- `player.lua` — player, shield, powerup creation
- `enemies.lua` — all enemy types (disc, flap, blob, green, lazer, static, spinshot, etc.)
- `utils.lua` — shared utilities (spline reading, easing, etc.)
- `levels.lua` — compact level loader (~17 lines). Reads `spawn_dat` string, builds `spawn_tab`.
- `spawn_tab_compact.lua` — canonical level data. Two levels separated by `|`. Format: `offset,class,func,params...` with relative distances.
- `textbox.lua` — dialog/textbox rendering
- `level_intros.lua` — level intro logic (currently stub)

### Gameplay cart 2 — `gameplay_2.p8` (level 3 flight)
Same engine includes as gameplay_1. L3 enemies + end-of-level results.
Loads `boss.p8` at end of level.
- `spawn_l3.lua` — level 3 spawn data (stub, expand with enemies)

### Boss cart — `boss.p8` (not yet built)
Boss taunts/dialog + boss fight + win screen.
- `boss.lua` — boss-only enemies: `add_enemy`, `mine`, `boss`, `boss_attach`, `line_shot`
On game over or win: loads `shootinator.p8`.

### Dev/test carts (do not merge into game carts)
- `enemytest.p8` — active dev cart for testing enemy scenes. Reference boss code at commit `dbc0c08`.
- Various others (`collision-test.p8`, `spline.p8`, etc.) — provenance unclear, candidates for cleanup

## Token counts (as of multi-cart split, gameplay_1 rename)
Use `info` in Pico-8 on the non-combined cart for accurate counts.
`combine.py` now handles indented `#include` — editor count on combined file should match.

- **shootinator.p8**: stub only, trivial
- **gameplay_1.p8**: 6936 / 8192 tokens (~1256 free) — room for new L2 enemy
- **gameplay_2.p8**: 8171 / 8192 tokens (~21 free) — will gain room once boss.lua + title screen code removed
- **boss.p8**: not yet built

## Goals

1. **3 levels** — practical, level data is cheap in compact string format
2. **Boss at the end of level 3** — boss code moves to `boss.p8`
3. **Multi-cart** — implemented. Flow: `shootinator.p8` → `gameplay_1.p8` → `gameplay_2.p8` → `boss.p8` → `shootinator.p8`
4. **Lines within 32 chars** — general style goal; **exception: boss code is exempt**
5. **Readable code** — general goal; **exception: boss code uses the `_ENV` trick** — intentional.

## Level design status

- **Level 1**: Done. Green, disc, flap enemies. Data in `spawn_tab_compact.lua` (first section).
- **Level 2**: Direction decided. Core composition: scrolling geometry (via map — undo map hack first), mines as environmental hazard (drop clusters in corridors), lazer turrets as anchors with dynamic enemies around them. Support enemies: greens, discs, spline-shooter. Flaps not a good fit alongside turrets/blobs. Data in `spawn_tab_compact.lua` (second section, after `|`). **Currently hardcoded as `level=2` in `init_game()` for testing.**
- **Level 3**: Stub — boss spawn only in `spawn_l3.lua`. No intro enemies yet. Boss moves to `boss.p8`.

## Cart structure

- **`shootinator.p8`** (launch): Title + story. Loads `gameplay_1.p8`. Game over from any cart returns here.
- **`gameplay_1.p8`** (gameplay_1): Levels 1+2. On level 2 complete: saves score/lives/powerups to cartdata slots 1-5, calls `load("gameplay_2.p8")`.
- **`gameplay_2.p8`** (gameplay_2): Level 3 flight + enemies. On complete: saves state, calls `load("boss.p8")`.
- **`boss.p8`** (not yet built): Boss fight. On win/game over: `load("shootinator.p8")`.

### Cartdata slots
- 0: hi-score (existing)
- 1: score
- 2: lives
- 3: spread
- 4: rapid
- 5: str_shield (1 or 0)

## Within-cart level progression (not yet implemented)
Level 1 → level 2 transition within `gameplay_1.p8` is not coded. Currently `level=2` is hardcoded in `init_game()` for development. A lightweight `init_level()` is needed that resets `d`, rebuilds `spawn_tab`, clears enemies, keeps player state.

## Known boss bugs
- **Arms don't die with the boss** — **FIXED** in `boss.lua`: `boss_attach.upd` checks `boss.hp<=0` and removes itself.
- **Mines were working but in an early state** — needs playtesting to assess.
- Other bugs TBD — rediscover by playing `boss.p8` once built.

## Spawn data format
```
offset,class,func,params...
```
- `offset`: distance from previous spawn (relative, accumulates)
- `class`: `en` (enemy, added to enmys) or `pup` (powerup, self-manages)
- `func`: function name (looked up via `_ENV[name]`)
- `params`: passed directly to the function

Levels separated by `|`. The loader in `levels.lua` uses `level` variable to pick the right section.

## Credits (for shootinator.p8 credits screen)

### Direct credits
- **lokistriker** — main gameplay music. Sent via Discord. Currently only noted as "bob" in cart headers.
- **pancelor** — spline suggestion. Discord: https://discord.com/channels/215267007245975552/215268097441923075/995111340664430602
- **paraK00PA** — both portrait sprites: player character and alien. Provided as .p8 files via Discord, July 2022. Requested credit as `paraK00PA`.
- **atticurse** — contribution unclear (not art, not code). Moved to special thanks.
- **easeoutbounce author** — function taken from https://www.lexaloffle.com/bbs/?tid=40577. Check thread for name.

### Special thanks
- **atticurse** — provided something during development; exact contribution unclear.
- **LouieChapm** — ongoing support.
- **Aktane** — early community support; helped with the bullet engine alongside otto.
- **LokiStriker** — again, for community support beyond the music.
- **...and all the other members of the Lazy Devs Discord** — catch-all for the wider community (otto, Eric, etc.).

### Acknowledgements
- **Krystman / Lazy Devs Academy** — shmup tutorial series provided structural goals; no code used directly.

## Dev notes

### L2 map scrolling (geotest.p8)
- Map draw call must come **after** `draw_stars()`, not before. Stars draw into black pixels of map tiles otherwise.
- `palt(0,false)` required before `map()` call — without it, tile colour 0 is transparent and stars bleed through solid geometry.
- Trade-off: stars don't appear behind edge tiles of the map. Acceptable — solid walls occluding stars is more correct than the alternative.
- Scroll speed: 0.25ppf used in geotest due to limited map rows available. 0.5ppf preferred for gameplay feel.
- **Map space strategy (settled):** Use upper map only for geometry within the cart. Extend level length by storing additional map sections in dedicated carts and loading them into himem via `reload()`. At scroll transition points, `memcpy` the next section over the live map — one-time cost per transition, no per-frame overhead. Overlap one screen's worth of tiles at each seam to hide the switchover. Up to 3 "banks" possible this way.
- **Rejected approaches:**
  - Per-frame spritesheet swap (two `memcpy`s per frame — too costly and unclean).
  - Sprite renumbering — sprite numbers are sometimes calculated by expression, making static search-and-replace unreliable.

## Accurate token counting
- Run `info` in Pico-8 on the **non-combined** `.p8` file — this is authoritative.
- `combine.py` now handles indented `#include` (fixed). Combined file editor count should match `info`.
- Do NOT use the editor count on the non-combined file with includes — it undercounts.
