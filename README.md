# walker-jumpman-zhefan

CSYE 7270 Assignment 1 — an extension of the **walker-jumpman** starter by
Nik Bear Brown (https://github.com/nikbearbrown/walker-jumpman, starting
revision `9387542`).

Two changes: a new character drawn entirely in code, and a second half of
the level built around timing and precision rather than longer jumps.

**Engine:** Godot 4.7.2.stable (win64), Compatibility renderer, GDScript
**Tested on:** Windows 11

---

## Run it

1. Install Godot 4.7.2 (standard build, not .NET).
2. Open `godot/project.godot` in the Godot editor.
3. Press **F5**.

### Controls

| Key | Action |
|---|---|
| A / D or ← / → | Move |
| Space | Jump |
| R | Retry the attempt |
| Esc | Pause |
| Enter | Start / resume / play again |
| M | Main menu (from the pause panel) |

### Automated tests

```
Godot_v4.7.2-stable_win64_console.exe --path godot --headless -s res://tests/test_game.gd
```

Expected: `WALKER TESTS: 26 checks / 0 failures`. Each run writes a result
file to `evidence/`.

---

## What I changed

### Character

The starter's humanoid is replaced with a bone-coloured automaton: a
tapered head with three square prongs, a single teal gem, a ribbed collar,
a blue cape, a belly glow, arms, and thrusters that fire only in the air.

- Facing is shown by the gem swinging to the edge of the head.
- The starter had no airborne visual at all. Now the thrusters fire, the
  gem grows and changes colour, the ball and belly glow brighten, and the
  arms lift. The flame is longer rising than falling.
- The collider, movement tuning and all gameplay code are unchanged. The
  new drawing sits inside the collider more tightly than the starter's did.

### Level

The level is 1472 px wide instead of 960. Sections 01 and 02 are unchanged;
the new section follows them:

- **Bounce pad** on the end of Ground C launches you up to an observation
  deck. It has its own constant; the normal jump is unchanged everywhere
  else.
- **03 / MIND THE CLOCK** — a platform that is solid for 1.8 s of every 3 s,
  blinks for the last half second, then shows only an outline while it's
  gone. You wait on the deck, read the rhythm, then go.
- **04 / THREAD THE NEEDLE** — a strip with two spike clusters and a 40 px
  slot between them. A full-speed jump overshoots it; you have to let go of
  the direction key in mid-air to land in it.
- **Finish** moved to the end of the new section.

The level drawing — hazards, background, grid, finish flag, labels — now
comes from the level data instead of fixed numbers in the code.

### Tests

The route test driver can now wait for the cycling platform and shorten a
jump in mid-air. A new check, `extension-landings`, confirms the route
actually stands on the deck, the cycling platform and the spike strip. No
existing assertion was removed or weakened.

---

## Known limitations

- **The menu text is out of date.** It still describes the level before the
  extension.
- GDScript doesn't fully conform to the official style guide — mainly
  line length, following the starter's style. Details in SOURCES.md.
- **The bounce pad ignores the jump button** on the tick it fires, so you
  always get the bounce (CHANGE-BRIEF.md Revision 3).
- **You can still jump for 0.1 s after the cycling platform vanishes**
  (coyote time). Kept deliberately — see FRICTIONAL.md entry 12.
- **Respawn keeps the facing you died with.** Starter behaviour, left
  unchanged.
- **The completion is touched in mid-air** at the top of the last hop,
  because the goal and a jump are both 56 px tall.
- **Visual and collision can differ by one physics tick** at the cycling
  platform's on/off boundary.
- **One drawing change inside section 01:** the step block's hatch marks no
  longer poke through its underside (CHANGE-BRIEF.md Revision 2).
- **The Godot 4.7.2 editor rewrites `godot/project.godot` on open** and drops
  `window/stretch/aspect="keep"` and the physics tick setting. Restore it
  with `git checkout -- godot/project.godot` after using the editor.
- **If any script fails to compile, the test suite loops forever** instead
  of exiting. Starter behaviour, not fixed.
- Only tested on Windows with Godot 4.7.2.

---

## Film

**Walker Jumpman: Mind the Clock | CSYE 7270**

- Link: https://drive.google.com/file/d/12hrSlaRKc5Z-YdK2Xz9igt2dUo6oxK65/view?usp=drive_link
- File: `claude-liam-walker-jumpman-walkthrough.mp4`
- SHA-256: `901342011a34abb816c26df6a88ef4378768d57b68d27564f5b3e5e359b8160c`
- Length: 6 min 51 s, 3840×2160
- Game revision shown: `d88860e`
- Made with Brutalist `godot-waikthrough` + `walker`. Gameplay is scripted
  input, labelled on screen. Film source is in
  `youtube/claude-liam-walker-jumpman-walkthrough/`.

---

## Documents

| File | What's in it |
|---|---|
| `CHANGE-BRIEF.md` | Plan and predictions, written before implementation, with revisions appended |
| `TEST-REPORT.md` | What was tested and what happened |
| `FRICTIONAL.md` | Learning log — what went wrong and what I did about it |
| `SOURCES.md` | Credits, tools, human and AI contributions |
| `SUBMISSION.md` | Submission details |
