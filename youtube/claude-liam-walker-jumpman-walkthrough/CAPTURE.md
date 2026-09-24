# CAPTURE.md — walker-jumpman walkthrough

Engine: **Godot 4.7.2.stable.official.ed1daf0bf** (win64 console build)
Host: Windows 11, NVIDIA RTX 5060 Laptop GPU, Compatibility renderer (OpenGL 3.3)
Game source revision demonstrated: **d88860e** (`origin/main`, pushed)

## Method

All takes are **scripted-input** engine runs recorded with Godot's Movie Maker.
No human playtest footage is included, and none of these are presented as one.

```
godot --path <capture-project> \
      --write-movie <reel>/capture/run-NN.avi \
      --fixed-fps 60 --quit-after <cap> --resolution 3840x2160
```

Movie Maker is **offline rendering, not evidence of real-time frame rate** — it
recorded at roughly 6–7% of real time. The simulation runs at the project's
pinned 60 physics ticks per second, so in-game timing and event order are
unaffected.

Output is native **3840×2160** MJPEG AVI at 60 fps, confirmed with `ffprobe`.
The game's logical canvas is **640×360**; 4K is an exact **×6** integer scale, so
nothing is resampled.

## Driver

`capture_driver.gd` (committed beside this file) drives the game through the
**normal input path**: every action is a real `InputEventAction` fed through
`Input.parse_input_event`, reaching both `session.gd::_unhandled_input` (menu,
confirm) and `player.gd`'s `Input.get_axis` / `is_action_just_pressed` polling.
The game is started from the menu with `confirm`, not by calling
`start_session()`.

The driver **reads** `player.position`, `player.is_on_floor()`, `game.state` and
`game.cycle_solid_left()` to decide when to press. It **writes nothing** to the
game: no position, no velocity, no state, no test-only shortcut, no collision
change. It runs at physics priority −20, ahead of the player (0) and the session
(10).

This is deliberately *not* `godot/tests/route_driver.gd`, which sets
`player.test_axis` / `test_jump_pressed` and bypasses `Input` entirely. The real
input path runs about one tick behind the test-variable path, so every landing
drifts right; the deck wait mark had to move from x 1078 to x 1070 to keep the
spike-slot hop clear of the first cluster.

Harness-only changes live in throwaway project copies under the session
scratchpad. The repository's own `godot/` project is unmodified.

### One harness accommodation, disclosed

`capture_main.gd` sets `game.test_mode = true` on the capture copy. In
`session.gd` that flag gates exactly one thing: `_on_focus_lost()` auto-pausing
the game. See "Two contaminated takes" below for why. Pause/resume itself is
unchanged and still reachable through Esc. No gameplay value is altered.

## Two contaminated takes, and the gate that caught them

A windowed Movie Maker recording runs for minutes on an ordinary desktop and is
**not isolated from it**. Two long takes were silently corrupted:

- the first `run-04` (9 min) diverged from three reproducible runs of identical
  inputs — the character jumped and moved with no corresponding driver input,
  fell, and died;
- the first `run-05` (10 min) ended in `state=2` — **PAUSED** — because the
  window lost focus and `_on_focus_lost()` paused the game mid-capture.

Neither was usable as evidence. Both were re-recorded after setting
`test_mode = true` (above) and with the window kept focused.

**Every 4K take is now gated** against a headless reference run of the same
driver and inputs: the two input logs must match action-for-action and
position-for-position. Tick indices may differ by a frame or two because a
windowed run resolves the menu slightly sooner; nothing else may differ.

| Take | events | vs headless reference |
|---|---|---|
| `run-01` | 28 | identical |
| `run-02` | 48 | identical |
| `run-04` | 29 | identical |
| `run-05` | 16 | identical |

## Takes

| Take | Mode | Frames | Duration | What it shows |
|---|---|---|---|---|
| `run-01` | scripted-input | 635 | 10.583 s | Menu start, full route, completion, 0 deaths |
| `run-02` | scripted-input | 1208 | 20.133 s | Deliberate miss on the cycling platform → death → retry → full route → completion, 1 death |
| `run-04` | scripted-input | 1175 | 19.583 s | Route stands on the deck through three full platform cycles, then commits and completes, 0 deaths |
| `run-05` | scripted-input | 1900 | 31.667 s | **Reconstructed intermediate state** — prediction 3 |
| `run-03` | — | 700 | 11.667 s | **SUPERSEDED, DO NOT USE** — first reconstruction attempt, built from the wrong level data (see below) |

### run-02 is a real failure

The driver commits to the cycling platform while `cycle_solid_left()` is 0 — the
platform is genuinely absent. The player falls past `fall_y` and the game's own
retry brings it back to spawn. Nothing was disabled, forced or faked to produce
the death, and the completion that follows is a real second attempt.

### run-04 waits by choice, not by trick

`watch_s` delays a decision the driver was already free to make, so the take
shows the platform blink, vanish and return before it commits. It changes
nothing about the game.

### run-05 is a reconstruction, not a commit

`run-05` does **not** correspond to any commit. The level data and the drawing
fix both landed in `8d64a7c`, so no revision ever contained the extended level
with the pre-fix drawing code. The state reproduced here is the **uncommitted
working tree** as it stood when prediction 3 was observed:

- everything from **`8d64a7c^`** (`cc5fafb`) — the pre-fix `session.gd`
- `levels/first_steps.json` **hand-reconstructed to the working-tree state**:
  width 1472; the bounce pad `[912,304,48,16]`, observation deck
  `[1008,224,96,16]`, cycling platform `[1168,224,64,16]` and spike strip
  `[1280,224,160,16]` all still plain entries in `solids`; hazards
  `[320,304,24,16]`, `[1320,208,24,16]`, `[1384,208,24,16]`; finish
  `[1408,168,24,56]`. No `pads` or `cycling` keys — those were introduced later,
  with the fix.

The player stands on the pad block to look across, which is how the failure was
originally seen. Every use of this take must be captioned as a **reconstructed
intermediate state**: a genuine engine run of a state that existed on a working
tree, never a historical revision.

**Why `run-03` was discarded.** It used `8d64a7c`'s committed JSON, where the pad
and cycling platform sit in `pads` / `cycling` keys that the pre-fix drawing code
does not read — so both platforms vanished from the shot, which is *not* what was
observed. Kept on disk, marked superseded, referenced by no beat.

## Hashes

`build_id` method: SHA-256 over the sorted list of files, hashing
`path \0 sha256(content)` for each, in path order. For `d88860e` the file list is
the tracked contents of `godot/`; for the reconstruction it is the whole
throwaway tree.

| Item | SHA-256 |
|---|---|
| build_id — `godot/` at `d88860e` (20 files) | `ca7854871e7935c5065726720033da86d91765d128084ad4df20370b7f939496` |
| build_id — `run-05` reconstruction tree (23 files) | `75e38a0b7428daadf65fd9412cc93b89a7cd103841cbc53cf8021f3905e920ab` |
| `capture/run-01.avi` (194,078,980 B) | `056348fcb7828e7730dcb3254bb2f23d04a4e1dc85296a3849a1aca77b0e3820` |
| `capture/run-02.avi` (366,660,164 B) | `762c5802a4695af2843fa3b6b7f12db1de2526d906cd70eeec65fca92e7b6d27` |
| `capture/run-04.avi` (367,805,778 B) | `3dd50a30ad90f7f269b8c6bb0290ade7ac0b5dd8f41137fbbe1a51d9a23ff95e` |
| `capture/run-05.avi` (477,115,360 B) | `452f2c63998bd3dc66ebd946f8ba6a76fa9861c9f37b0823e4ad5512f47fcf1d` |
| `capture/run-01-inputs.jsonl` (2,821 B) | `07c924d397670f440b1634dc6243e68ffcc6ac5448c42bc64677fd30b410faf1` |
| `capture/run-02-inputs.jsonl` (4,887 B) | `786b2207f6226640c238fabed82ef22e4904929b30680eb6399b03203857a988` |
| `capture/run-04-inputs.jsonl` (2,943 B) | `26bc7224e918d7c68e624677e8a156a757914d908bd561168860c58cbe12fb9f` |
| `capture/run-05-inputs.jsonl` (1,592 B) | `c977170de658d54fd74752d6ede35e161e9187f4a3af1572f6fe2c16663f6fbf` |
| `capture/run-03.avi` — superseded (180,794,726 B) | `a516a5e6c92a4d3e767f22644f26a89413301144966f429edf2495f2534cd6a6` |

`capture/` and `exports/` are gitignored; the takes are large and reproducible
from the committed driver plus the recorded revision. Re-recording changes the
capture hashes but not the build_id.

## Audio

The game produces no audio. Nothing is muted, and no sound effects were invented.
Liam's narration is the only audio track; the regular outro card carries only the
stock jingle.

## Open

- `coverage.json` is not written yet — every evidence entry must reference a
  `beat_id` that exists in `beat_sheet.json` with narration.
- **Pause/resume (Esc) and manual restart (R) are implemented but appear in no
  take.** Under the coverage contract that blocks a "complete walkthrough" claim.
  Awaiting a human decision: record a fifth take, or do not claim completeness.
