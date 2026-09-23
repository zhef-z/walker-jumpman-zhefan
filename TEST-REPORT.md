# TEST-REPORT

**Engine:** Godot 4.7.2.stable (win64), Compatibility renderer, OpenGL 3.3
**OS:** Windows [fill in version]
**GPU:** NVIDIA GeForce RTX 5060 Laptop GPU

Results below are what I actually observed. Anything not yet checked is
marked as such.

---

## Baseline — starter, before my changes

**Revision:** [fill in — 9387542 or 7f19b50]

Played the starter by hand before changing anything.

- **Controls:** A/D or arrows to move, Space to jump, R to retry, Esc to
  pause. All responded.
- **Level:** two sections, "01 / GET MOVING" and "02 / MIND THE GAP", with
  a FINISH flag at the right end.
- **Pause:** Esc opens a "Take a breath." panel; Enter resumes.
- **Completion:** "Course complete." panel with the time and retry count;
  Enter to play again.
- **Timer:** the time on the completion panel is for the successful
  attempt only, not total time across retries. Retries accumulate.
- **Failure:** hitting spikes and falling into a gap give different
  messages.
- **Respawn:** [fill in — where the player reappears after death]
- **Existing problems noticed:** [fill in, or "none found"]

---

## Automated checks

**Command:**

```
Godot_v4.7.2-stable_win64_console.exe --path godot --headless -s res://tests/test_game.gd
```

### Run 1 — after the character change (failed to compile)

The suite never ran. `player.gd` failed to parse:

```
SCRIPT ERROR: Parse Error: Assigned value for constant "HEAD" isn't a constant expression.
   at: GDScript::reload (res://features/player/player.gd:22)
```

Everything downstream then failed to load, and the harness looped on a null
player until stopped. Zero checks executed. Cause and fix are in
FRICTIONAL.md entry 6.

### Run 2 — after changing `const HEAD` to `var HEAD`

```
WALKER TESTS: 25 checks / 0 failures
```

Values worth recording:

| Check | Observed | Meaning |
|---|---|---|
| `fixed-jump-and-no-double` | rise 56.07 px | assertion is 53.33 ± 5; the engine's per-tick integration overshoots the textbook value, as expected |
| `complete-real-route` | 325 ticks, 5 of 5 jump marks used, 0 deaths | original route unaffected |
| `low-ceiling` | minimum feet y 300.0003 | unchanged — collider untouched |

Evidence file written: `evidence/mechanics-1790154658.703.json`

Both headless runs left `project.godot` unchanged (same md5), so the
settings regression in FRICTIONAL.md entries 1–2 comes from the editor, not
from running the project.

**Limit of this evidence:** headless mode uses a dummy renderer, so
`_draw()` never runs. A green suite proves the script compiles and gameplay
is unchanged. It says nothing about how the character looks.

---

## Character appearance

Checked in a windowed run.

| Check | Result |
|---|---|
| Concave head polygon renders correctly | ✅ three prongs, two notches, nothing missing or filled in |
| Standing, facing right | ✅ gem at the right edge of the head |
| Standing, facing left | ✅ gem at the left edge of the head |
| Console during play | ✅ engine start-up lines only, no errors or warnings |
| Airborne, facing readable | ❌ first version recentred the gem → ✅ after revision |
| Thrusters appear when airborne | ✅ |
| Flame longer rising than falling | [not yet checked] |
| Visual vs collider alignment | [not yet checked] |
| Facing after respawn | keeps the facing you died with — left unchanged by design |

Screenshots: [add filenames]

---

## Inspect-and-revise cycles

### 1. Airborne facing

**Observed:** when I jumped, the gem moved back to the centre of the head.
In the air I couldn't tell which way the character was facing.

**Judgement:** the recentre was my own design choice, meant to signal
"airborne". It traded away facing information at the moment my new section
needs it most — landing between the spike clusters. The other four airborne
cues (thrusters, raised arms, larger ball, brighter belly) already signal
airborne on their own.

**Change:** the gem keeps its facing offset in the air; only size and
colour change.

**Re-test:** jumped facing right and facing left. The gem stays at that side
of the head in the air; facing is readable throughout the jump.

### 2. Cycling platform

**Observed:** the platform never blinked and always drew fully solid, but
I fell through it when landing.

**Cause:** the level was drawn once in _ready() and never redrawn, so the
visual froze. Collision was toggling correctly underneath.

**Change:** redraw the level every tick while a cycling platform exists.

**Re-test:** solid, then a half-second blink, then a faint outline
while absent, repeating. Falling through only when visibly gone. ✅

---

## Level extension

### Prediction 3 — observed before the fix

With only the level data changed, standing at the right end of Ground C:

| Expected by the brief | Observed |
|---|---|
| New spikes drawn ~96 px below the strip | ✅ floating in empty air below a bare strip |
| FINISH label stays at the old finish | ✅ still over Ground C |
| Grid stops at the old width | ✅ hard edge at x 960 |
| Background rect stops short | not visible — same colour as the clear colour |

Screenshot: [add filename]

### After fixing the drawing

Regression check, done numerically by Claude Code: old and new drawing
formulas evaluated on the original level data. Original hazard
[320, 304, 24, 16] — all three spikes identical vertex for vertex. Old
finish flag and label identical. Hatch marks identical on four of five
original platforms; the fifth (section 01 step block) deliberately
changed, see brief Revision 2.

Checked in play:

| Check | Result |
|---|---|
| New spikes sit on the strip | ✅ |
| Finish flag at the new finish, correct height | ✅ |
| FINISH label follows the finish | ✅ |
| 03 and 04 section labels present | ✅ (04 moved left to clear the flag) |
| Bounce pad visibly different | ✅ |
| Bounce reaches the observation deck | ✅ |
| Pressing jump on the pad still bounces | ✅ |
| Level can be completed by hand | ✅ |
| Sections 01 and 02 play as before | ✅ |
| Camera follows across the full 1472 px level; finish and labels visible | ✅ |

### Route test

**Before:** after the level data changed, the old route could no
longer finish — it ran out of jump marks at x 712 and couldn't wait for
the cycling platform. Left failing until the level was complete.

**What changed in the fixture:**
- route_driver.gd: jump marks became records with optional wait
  (stand still until the cycling platform has at least 0.9 s of solid
  time left) and hold (release right after N ticks to shorten the
  arc). New marks past x 712 cover the bounce pad, the deck, the
  cycling platform, the spike slot and the final hop.
- session.gd: added a read-only cycle_solid_left() query so the driver
  doesn't duplicate the cycle maths. No behaviour change.
- test_game.gd: new check extension-landings — the route must actually
  stand on the deck, the cycling platform and the spike strip, so a
  route that skipped a tier by luck can't pass.
- No assertion removed or weakened. complete-real-route still requires
  COMPLETE with zero deaths within 900 ticks.

**After:** WALKER TESTS: 26 checks / 0 failures. Route completes in 536
ticks, identical across two consecutive runs.

**Note:** the route finishes in mid-air, touching the goal area at the
top of its last hop. The goal is 56 px tall and so is a jump, so any
approach that clears the second spike cluster enters the goal before
landing.

---

## Predicted failures — results

| Prediction | Result |
|---|---|
| 1. Cycling platform timing wrong in either direction | Not observed. Had to wait and watch the rhythm (not too long); never caught by it vanishing before I could jump (not too short). No exact attempt count kept. |
| 2. Jumping as the platform vanishes | Confirmed — jump succeeds just after it vanishes. Kept deliberately, see FRICTIONAL entry 12. Buffered landing not skipped. |
| 3. New spikes drawn in the wrong place | Confirmed before the fix, fixed, see Level extension. |

---

## Movement checks

| Check | Result |
|---|---|
| Coyote: step off a ledge, jump immediately | ✅ jumps |
| Buffer: press jump just before landing | ✅ jumps on contact |
| Failure and recovery in the new section | ✅ retries normally |

---

## Not yet tested

- Flame longer rising than falling (appearance table)
- Visual vs collider alignment (appearance table)
