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
| Facing after respawn | [not yet checked] |

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

---

## Not yet tested

- Level extension (bounce pad, observation deck, cycling platform, spike
  strip, moved finish)
- Failure and recovery in the new section
- Camera and presentation across the wider level
- Updated route test fixture
- Coyote time and jump buffering
