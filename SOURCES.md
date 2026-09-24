# SOURCES

## Starter

**walker-jumpman** by Nik Bear Brown — https://github.com/nikbearbrown/walker-jumpman
Starting revision: `9387542`
Licence: **none stated.** The checkout contains no LICENSE or COPYING file,
and the GitHub API reports no licence set on `nikbearbrown/walker-jumpman`.
The only licence wording in the starter's own documents is a remark in
GDD.md that "the toolkit's upstream MIT license is not a blanket provenance
record" — that refers to the Walker toolkit, not to this game's source.
Used here with the instructor's permission as the assignment's starter.

Everything in this repo not listed under "My changes" in README.md is the
starter's, including the movement code, the tuning values, the retry and
pause logic, the HUD, the menu, and the three screenshots in
`evidence/screens/`.

## Tools

| Tool | Used for |
|---|---|
| Godot 4.7.2.stable (win64), GDScript | Engine |
| Claude Code (Claude Opus 5), via Northeastern access | Wrote all code changes, ran the test suite, updated the route test, built the film |
| Claude (claude.ai chat) | Design discussion, character mock-ups, coordinate and jump-distance calculations, drafting the Markdown documents |
| Gemini | Summarised one course video ("Clawd in Walker Jumpman: First Playthrough"), and reviewed the finished film |
| Brutalist toolkit — https://github.com/nikbearbrown/brutalist.art, `godot-waikthrough` skill with the `walker` modifier | Film production |
| Kokoro TTS (`am_onyx` voice, "Liam") | Film narration |
| Remotion, ffmpeg | Film rendering and encoding |

Licences for Brutalist, Kokoro, Remotion and the outro jingle:

| Component | Licence as found |
|---|---|
| Brutalist toolkit (`nikbearbrown/brutalist.art`) | **None stated.** No LICENSE file anywhere in the tree; the GitHub API reports no licence set on the repository. |
| Kokoro — `kokoro-onnx` Python wrapper | **MIT**, Copyright (c) 2025 github.com/thewh1teagle (`kokoro_onnx-0.6.1.dist-info/licenses/LICENSE`). |
| Kokoro — model weights (`kokoro-v1.0.onnx`, `voices-v1.0.bin`) | **None stated locally.** The files ship inside the toolkit; `setup` records their origin as the `thewh1teagle/kokoro-onnx` GitHub release `model-files-v1.0`, but no licence text accompanies them here. |
| Remotion | **Remotion License** (dual tier), Copyright © 2026 Remotion — `node_modules/remotion/LICENSE.md`. Free tier covers individuals, non-profits, and for-profit organisations with up to 3 employees, and permits creating videos commercially; it forbids selling or sublicensing a derivative of Remotion itself. This student project falls inside the free tier. |
| Outro jingle | **None stated.** A Brutalist stock asset from the toolkit's `svg/claude/mp3/` set, selected deterministically from the reel slug. No licence text accompanies it. |

Where a licence is marked "none stated", that is what the sources actually
say — nothing was inferred from convention.

## Art, audio and film assets

- **Character and all level visuals:** original geometric drawing in GDScript
  `_draw()` calls. No image, sprite or texture files were imported.
- **Character design inspiration:** the colour scheme and some features
  (a single gem eye, a cape, a collar, a pale bone body) were inspired by a
  robot character from *Slay the Spire 2*. I looked at a reference image and
  designed a simplified version; nothing from the image was traced or
  imported.
- **Game audio:** none. The game has no sound.
- **Film narration:** generated with Kokoro TTS through Brutalist.
- **Film outro jingle:** Brutalist stock asset.
- **Gameplay footage in the film:** recorded from this project with a
  scripted input driver, labelled on screen as scripted input.

## Collaborators

None.

## How much of the code I wrote

**About 100% of the code was written by AI (Claude Code). I hand-wrote 0 lines
of GDScript.**

That breaks down as:

- `godot/features/player/player.gd` — character drawing: Claude Code, from
  coordinates Claude (chat) worked out to fit the collider after I chose the
  design
- `godot/game/session.gd` — drawing fixes, bounce pad, cycling platform:
  Claude Code
- `godot/features/player/tuning.gd` — `BOUNCE_VELOCITY` constant: Claude
  Code
- `godot/levels/first_steps.json` — values: Claude, from the layout I
  decided on
- `godot/tests/route_driver.gd`, `godot/tests/test_game.gd` — Claude Code,
  within constraints I set
- Markdown documents — drafted by Claude, reviewed and revised by me
- `youtube/.../capture_driver.gd`, `capture_main.gd` — Claude Code
- Film script and beat sheet — drafted by Claude Code, reviewed and changed
  by me before voicing

## What I did

- **Character:** chose the concept and made every design call through
  several rounds — dropping a round seal for a rectangular shape, cutting
  the "cute" additions to keep the code explainable, switching to the
  automaton, then single eye, ball inside the head, lighter pupil, longer
  arms and shorter legs, smaller tapered head, three square prongs joined
  into one shape, and a much bigger eye swing for facing.
- **Level:** designed the structure — bounce pad, then a platform that
  blinks, then a landing between two spike clusters — and the rule that the
  new section should be harder through timing and precision, not longer
  jumps.
- **Predictions:** wrote the first two predicted failures myself (timing
  window wrong in either direction; jumping as the platform vanishes) and
  accepted the third.
- **Playtesting:** found by playing that the gem lost facing in the air and
  that the cycling platform looked solid while dropping me through it.
  Noticed the film's first cut had no continuous playthrough. Ran the
  prediction tests and the movement checks by hand.
- **Decisions:** kept the coyote jump off a vanished platform; left facing on
  respawn unchanged; left the stale menu text as a stated defect instead of
  re-recording; agreed to add the level data before fixing the drawing so
  prediction 3 could be seen; chose the film's title, verdict and Your Turn experiment.
- **Review:** reviewed diffs before approving them, and sent back or denied
  several. Reviewed the film script with Claude before it was voiced.

## Code style

Reference: the official Godot GDScript style guide
(https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html).
The code I changed follows the starter's existing conventions rather than
fully conforming to the guide. A check by Claude Code found 15 deviations in
lines added by my changes — mostly lines longer than 100 columns in the
`_draw()` code, matching the starter's dense one-line style, plus `HEAD` left
in CONSTANT_CASE after it was changed from `const` to `var` — and 25 inherited
from the starter. I didn't fix them, because changing game source after the
film was rendered would mean the film no longer shows the submitted code.
Listed as a known limitation.

---

## LABOR SEPARATION DISCLOSURE

**Stage reached:** Revise

The game went through brief, build, playtest, inspect and revise. No
standalone exported application was built; the assignment doesn't require
one.

**AI did:** Claude Code wrote all GDScript changes (character drawing,
drawing fixes, bounce pad, cycling platform, route test driver and new
check), ran the automated tests, verified regressions numerically, and
produced the film with Brutalist. Claude (chat) produced character
mock-ups, worked out coordinates and jump distances, and drafted the
Markdown documents. Gemini summarised a course video. Kokoro generated the
narration.

**Human did:** set the intent and every design decision for the character
and the level; wrote the first two predictions and accepted the third;
playtested every section by hand; found two problems by playing; decided
what to keep, change or leave as a stated defect; reviewed diffs before
approving them; reviewed the film script before it was voiced; wrote the
film's verdict.

**Supervisory capacity exercised:** PA — Plausibility Auditing

**Specific instance:** Claude Code implemented the cycling platform and the
code looked right — it compiled, parsed cleanly, and the collision toggling
was correct. When I played it, the platform never blinked and always looked
solid, but I kept falling through it. The level was only drawn once at
start-up, so the picture had frozen on its first frame while the collision
underneath kept switching on and off. Nothing errored. I reported what I
saw, Claude suggested two possible causes, and Claude Code confirmed the
cause, and the level now redraws every tick
while a cycling platform exists. Re-tested by playing: it blinks, fades to
an outline, and only drops me when it's visibly gone.

**Also exercised:** IJ — Interpretive Judgement. My first design had the
gem recentre in the air to signal "airborne". Playing it, I realised that
threw away facing at exactly the moment the spike slot needs it, so I
changed it (CHANGE-BRIEF.md Revision 1).
