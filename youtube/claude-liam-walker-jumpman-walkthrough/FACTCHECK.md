# FACTCHECK — Walker Jumpman: Mind the Clock | CSYE 7270

Every factual claim in `SCRIPT.md`, with its source. Sources are the repository's
own records (`CHANGE-BRIEF.md`, `TEST-REPORT.md`, `FRICTIONAL.md`), game source
files at **d88860e**, or a capture in `capture/`. Nothing here is sourced to
memory or inference unless the row says so.

Status: **DRAFT — pending human sign-off. No audio generated.**

| # | Beat | Claim | Source | Verdict |
|---|---|---|---|---|
| 1 | B00 | The prompt is a reconstruction written back from the change brief, not a session transcript | `SCRIPT.md` B00 on-screen label; `CHANGE-BRIEF.md` header — "Written before I changed anything" | stated as reconstruction ✅ |
| 2 | B01 | Starter is walker-jumpman, a control/retry slice: three ground slabs, one spike cluster, two gaps, a finish flag | `godot/levels/first_steps.json` at `9387542` — 3 ground solids, 1 hazard, gaps 448→512 and 736→784, finish; `first_steps.json` `scope` field | ✅ |
| 3 | B01 | Starter commit is 9387542 | `git log`; `9387542` "Add Walker Jumpman playable First Steps prototype" | ✅ |
| 4 | B01 | 512 more pixels of level | `first_steps.json` width 960 → 1472 (commit `8d64a7c`) | ✅ 1472 − 960 = 512 |
| 5 | B01 | The design document proposes cherries, three zones and sound; none built | `GDD.md` (33 mentions of cherries, "Three-zone", audio/sound); `first_steps.json` `scope`: "Control/retry slice, not the proposed full three-zone course" | ✅ |
| 6 | B01 | Revision shown is d88860e | `git rev-parse`; pushed to `origin/main`; `CAPTURE.md` build_id | ✅ |
| 7 | B02 | Gaps are 64 px and 48 px | `CHANGE-BRIEF.md` §2 table; `first_steps.json` 512−448=64, 784−736=48 | ✅ |
| 8 | B02 | One press, no double jump, no variable height | `GDD.md` §"Rule"; `player.gd` `_physics_process` (single `opportunity_consumed`); completion card text "One jump. No double jump. Unlimited retries." | ✅ |
| 9 | B02 | Hatch marks used to poke 3 px through the step block's underside; clamp fixed it; collision unchanged | `CHANGE-BRIEF.md` Revision 2; numeric regression run — platform `[160,304,48,16]` overshoot +3 px → 0 px | ✅ |
| 10 | B03 | Starter had no airborne state; walk cycle gated on floor + movement; mid-air drew as standing idle | `CHANGE-BRIEF.md` §1 "The airborne thing"; `player.gd` at `9387542` — `stride` gated on `is_on_floor() and absf(velocity.x) > 8` | ✅ |
| 11 | B03 | Flame is longer going up than coming down | `player.gd` `_draw()` — `flame := 7.0 if velocity.y < 0 else 4.0`; **measured in `run-01`**: 6.7 logical px at 2.50/2.60 s (rising) vs 3.3–3.7 at 2.75/2.90/3.00 s (apex and after) — `_qc/flame-strip.png` | ✅ visually verified from the capture |
| 12 | B03 | First version recentred the gem in the air and lost the facing cue; it stays put now | `CHANGE-BRIEF.md` Revision 1; `TEST-REPORT.md` Inspect-and-revise 1 | ✅ |
| 13 | B04 | Pad constant −480 vs jump −320 | `tuning.gd` — `BOUNCE_VELOCITY = -480.0`, `jump_velocity = -320.0` | ✅ |
| 14 | B04 | Rise goes from ~53 px on paper / 56 measured, to ~120 px | `CHANGE-BRIEF.md` §2 (53 px, 120 px, textbook); measured 56.07 px in `evidence/mechanics-1790159551.352.json` check `fixed-jump-and-no-double` | ✅ both figures given, labelled |
| 15 | B04 | Jump velocity unchanged everywhere else | `tuning.gd` diff at `8d64a7c` — `jump_velocity` untouched; `CHANGE-BRIEF.md` Revision 3 | ✅ |
| 16 | B04 | A jump pressed on the pad would have overwritten the launch a tick later; the pad now discards it | `CHANGE-BRIEF.md` Revision 3; `session.gd::_apply_pads` sets `opportunity_consumed` and clears `jump_request_tick` | ✅ |
| 17 | B05 | Three-second cycle, solid 60% of it | `first_steps.json` — `"cycle": 3.0, "on_ratio": 0.6` | ✅ |
| 18 | B05 | Blinks for the last half second; warning, not polish | `session.gd::_cycle_phase` — `warn` window `on − 0.5`; rationale in `CHANGE-BRIEF.md` §2 "Cycling platform" | ✅ |
| 19 | B05 | Route commits only with ≥0.9 s solid left; the jump takes ~0.7 s | `capture_driver.gd` `needed_solid = 0.9`; `CHANGE-BRIEF.md` §2 airtime ≈ 0.67 s (41 ticks / 60 = 0.683) | ✅ |
| 20 | B06 | The driver reads zero solid time left and jumps anyway; nothing staged | `capture/run-02-inputs.jsonl` — `deliberate_miss` at tick 471, `cycle_solid_left: 0.0`; `capture_driver.gd::_commit` | ✅ |
| 21 | B06 | The miss is deliberate, the death is the game's physics; falls past the kill line; retry returns it to spawn; it replays the route and completes | `run-02-inputs.jsonl` respawn tick 575 `deaths: 1` at x 64.0; `session.gd` `fall_y` 430, `retry_remaining = 0.55`; run ends `state=4` (COMPLETE) `deaths=1` | ✅ completion after retry confirmed |
| 22 | B07 | Hazard drawing read only x; count, width, base and tip were fixed numbers | `session.gd` at `8d64a7c^` lines 198–201 — `entry[0] + i*8`, literals 320 / 304, `range(3)` | ✅ |
| 23 | B07 | The literals matched the original hazard only by coincidence | `CHANGE-BRIEF.md` §4 prediction 3; original hazard `[320,304,24,16]` → 3 spikes × 8 px, base 320, tip 304 | ✅ |
| 24 | B13 | New spikes draw ~96 px low while the strip stays bare; the kill box stays correct | `CHANGE-BRIEF.md` Revision 4 ("roughly 96 px low"); 320 − 224 = 96; `capture/run-05.avi` and `_qc/run-05-prediction3.png` (reconstructed working-tree state; see CAPTURE.md); trigger built from `rect.size` in `_add_area` | ✅ observed in capture |
| 25 | B13 | Nothing errored — it compiled and ran | `capture/run-05.avi` runs to completion; `TEST-REPORT.md` Level extension | ✅ |
| 26 | B07 | Regression check was numeric: old and new formulas compared vertex by vertex on the original data; the three original spikes came out identical | `TEST-REPORT.md` "After fixing the drawing"; `FRICTIONAL.md` entry 9 | ✅ |
| 27 | B08 | 40 px slot, 18 px character, 22 px window | `first_steps.json` hazards at 1320 and 1384 → 1384 − 1344 = 40; `player.gd` collider `Vector2(18, 28)`; `CHANGE-BRIEF.md` §2 "22 px window" | ✅ |
| 28 | B08 | A full-speed jump covers ~109 px and overshoots the slot from anywhere standable; the route must release right mid-air | `FRICTIONAL.md` entry 13; `capture_driver.gd` `hold` on marks 8 and 9 | ✅ |
| 29 | B09 | 9.1 seconds, zero retries | `capture/run-01.avi` completion card, visible at 10.0 s; `_qc/run-01-finish.png` | ✅ |
| 30 | B09 | Goal is 56 px tall, a jump is 56 px high, so anything clearing cluster two is in the goal before landing | `first_steps.json` finish `[1408,168,24,56]`; `TEST-REPORT.md` Route test **Note**; measured rise 56.07 px | ✅ |
| 31 | B10 | 26 automated checks, 0 failures; route 536 ticks, identical across two runs | `TEST-REPORT.md` Route test; `evidence/mechanics-1790159551.352.json` and `…577.461.json` | ✅ |
| 32 | B10 | Menu still reads "Cross two gaps. Clear the spikes. Reach the flag." | `godot/ui/hud.gd` line 40 | ✅ |
| 33 | B10 | Visual-vs-collider alignment is untested | `TEST-REPORT.md` "Not yet tested" | ✅ |
| 34 | B10 | Coyote jump off a vanished platform works; 0.1 s; kept on purpose | `tuning.gd` `coyote_ticks = 6` at 60 Hz = 0.1 s; `CHANGE-BRIEF.md` Revision 4; `FRICTIONAL.md` entry 12 | ✅ |
| 35 | B10 | Feel/fun verdict | Supplied verbatim by Zhefan Zhang; quoted, not paraphrased, and attributed on screen | ✅ human judgement, labelled |
| 36 | B11 | Design, predictions and play judgements are Zhefan Zhang's; Claude Code implemented, checked and captured | `FRICTIONAL.md` **Human / AI** lines, entries 8–13 | ✅ |
| 36b | B11 | Every section was played by hand separately; the recentring gem and the frozen platform were found that way; those playtests are in the test report | `FRICTIONAL.md` entries 7, 11, 12; `TEST-REPORT.md` Inspect-and-revise 1 and 2 | ✅ |
| 37 | B11 | All gameplay is scripted input, not a human playtest | `CAPTURE.md`; `coverage.json` `method: scripted-input`; on-screen labels | ✅ |
| 38 | B12 | Moving the second cluster 1384 → 1376 makes the slot 32 px, leaving a 14 px window | `first_steps.json`: 1376 − 1344 = 32; 32 − 18 = 14 | ✅ arithmetic from source |

## Claims deliberately NOT made

- No claim about frame rate or performance. Movie Maker recorded at ~6–7% of
  real time; that is offline rendering, and the film says nothing about FPS.
- No claim that the route is a human playtest, or that the game is fun,
  fair or accessible, beyond the designer's own quoted sentence.
- No claim that the walkthrough is *complete*. `run-05` demonstrates a
  reconstructed defect, not a feature; pause/resume and manual restart are
  implemented but not shown in these three takes (see Open, below).

## Open

- **Coverage completeness.** `session.gd` implements pause/resume (`Esc`) and
  manual restart (`R`); neither appears in any take. Under the coverage
  contract an implemented-but-unshown feature blocks the "complete walkthrough"
  claim. Either a fourth take is needed, or the film must not claim completeness.
  Flagged for the human decision before `coverage.json` is written.
