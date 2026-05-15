# Shootinator - Project Context

## What this is
A Pico-8 shoot-em-up. The main cart is `shootinator.p8`. There are several other `.p8` files which are **development/test carts**, not part of the final game.

## File map

### Main cart
- `shootinator.p8` — the game. Includes all the files below at runtime.

### Lua includes (all used by shootinator.p8)
- `mob.lua` — base mob creation and default behaviours
- `player.lua` — player, shield, powerup creation
- `enemies.lua` — all enemy types (disc, flap, blob, green, lazer, spinshot, etc.)
- `utils.lua` — shared utilities (spline reading, etc.)
- `levels.lua` — **current** level loader. Reads binary-packed data from cart memory. Complex parser, token-heavy.
- `spawn_tab_compact.lua` — compact string format of the level data. Intended to **replace levels.lua** (see below).
- `spawn_tab_decoded.lua` — fully decoded explicit Lua table format. Too verbose, too many tokens. Do not use.
- `textbox.lua` — dialog/textbox rendering
- `level_intros.lua` — level intro logic

### Test/dev carts (do not merge into shootinator.p8)
- `enemytest.p8` — early, simple enemy test cart
- `enemytest2.p8` — advanced enemy test cart. Contains the **boss** code that needs merging into shootinator.
- Various others (`collision-test.p8`, `spline.p8`, etc.) — isolated experiments

## Goals

1. **3 levels** — practical, level data is cheap in compact string format
2. **Boss at the end of level 3** — the hard problem, see merge section below
3. **Single cart** — preferred, but user will accept multi-cart if single-cart proves intractable
4. **Lines within 32 chars** — general style goal; **exception: boss code is exempt** (token optimisation requires it)
5. **Readable code** — general goal; **exception: boss code uses the `_ENV` trick and compressed expressions** throughout — this is intentional and acceptable. The rest of the codebase should stay readable.

## Level design status

- **Level 1**: Done. Green, disc, flap enemies. Wesley is happy with it.
- **Level 2**: Partially designed. Focus mechanic: lazer turret. Support enemy: **unspecified, not yet implemented**. This is a design gap — a new enemy behaviour needs to be created before level 2 can be completed.
- **Level 3**: Not designed. Will end with boss fight.

## Side goals

- **Easier level creation** — the current approach of hand-coding hex values into cart memory and testing is painful. The `spawn_tab_compact.lua` format (plain text rows of `dist,func,params`) is already much more authoring-friendly. A separate level editor cart is the ideal end state but out of scope for now. At minimum, the compact text format should be the canonical way to define levels going forward — not the binary map memory format.
- **Relative spawn distances** — the original binary format uses *relative* distances (offset from previous spawn), not absolute. This makes it easy to insert or remove a block of spawns in the middle of a level without renumbering everything after it. **This must be preserved.** Note: `spawn_tab_compact.lua` as currently generated uses *absolute* distances — this is a known regression that needs fixing before it becomes the canonical format. The loader should accumulate relative offsets, not use the values as absolute distances.

## Multi-cart structure

Suspected to be necessary. Cart splits must happen **between levels**, never mid-level.

Two clean types of cart boundary:
1. **Dialog/cutscene carts** — pure UI, no gameplay state going in. Pass only "which dialog to show" and "which level to load next" via cartdata. These get a fresh token budget for presentation with no gameplay overhead.
2. **Gameplay carts** — receive score, lives, powerup state from cartdata. Each level (or pair of levels) is self-contained.

Each level should have its own dialog. Separating UI from gameplay is both a clean separation of concerns and better UX.

Proposed structure:
- **`intro.p8`**: Title + level intro dialogs. Reads target dialog from cartdata, loads appropriate gameplay cart when done.
- **`gameplay_1.p8`**: Levels 1 + 2. On complete, writes state to cartdata, loads `intro.p8` with level 3 dialog queued.
- **`gameplay_2.p8`** (boss cart): Level 3 + boss. New enemies: `mine`, `boss`, `boss_attach`, `line_shot` (~1208 tokens). Fresh 8192 token budget.

State handoff via `cartdata()` (16 persistent slots). Slot 0 is already hi-score. Remaining needed: score, lives, powerup flags (spread, rapid, shield), current dialog/level index. ~6 slots total.

## The merge problem (work in progress)

**Goal:** Add the boss fight from `enemytest2.p8` into `shootinator.p8`.

**The blocker:** Token budget. Pico-8 limit is 8192 tokens. The boss code is ~1000 tokens and was pushing the cart over the limit.

**Before making any changes, ask the user for the current token count.**
To get an accurate count, the user must: export the cart (which inlines all includes), re-import it, then read the token count from the Pico-8 editor. The in-editor count with includes is inaccurate.

## Planned token savings

### levels.lua → spawn_tab_compact.lua (not yet done)
Replacing `levels.lua` with a compact loader for `spawn_tab_compact.lua` saves an estimated ~200 tokens. The compact format stores all level data as a single multi-line string (1 token). A small loader (~150 tokens) replaces the ~350-token parser in `levels.lua`.

The `spawn()` function in `shootinator.p8` expects entries with `.class`, `.func`, and `.params` fields — the new loader must produce this structure. Class is `"pup"` for `create_powerup`, `"en"` for everything else.

## Boss code location
In `enemytest2.p8`, the boss-related functions are:
- `make()` — small helper, builds a table from keys and varargs
- `mine()` — proximity mine enemy
- `boss()` — main multi-phase boss (spline movement, phase transitions)
- `boss_attach()` — wing attachments that spawn at phase 3
- `line_shot()` — falling laser attack used by boss

These would go into `enemies.lua` (already included) to keep `shootinator.p8` itself lean.

The win condition in `update_game()` triggers when `d >= total_dist and #enmys == 0`. The boss just needs to be the last enemy alive — no special win logic required.

## Known boss bugs / unimplemented behaviour

- **Arms don't die with the boss** — `boss_attach` adds each arm as a separate enemy with its own `hp`. When the boss dies, the arms remain in `enmys`. Fix needed: either the boss `die` function removes the arms explicitly, or the arms detect the boss is gone and remove themselves.
- **Source of truth**: the working (but buggy) boss is in git at commit `dbc0c08` in `~/pico-projects/shootinator`, in `enemytest.p8`. This is the February 2024 version. Use this, not `enemytest2.p8` (which is older, December 2023).
- Other bugs/unimplemented behaviour TBD — rediscover when playing the git version fresh.
