# RIFF — Walker Jumpman: Mind the Clock

Commentary pass over the captures, per `skills/make/riff/SKILL.md`. Each row was
written after inspecting the clip and its input log, not from a filename.
Observations are what is visible; interpretations are labelled as source-code
facts or as untested judgements. Narrator: **Liam, in for Bear**, Kokoro
`am_onyx`. The human judges fun; this pass does not.

Revision demonstrated: **d88860e**. All gameplay is scripted input.

---

### B02 · `run-01` 0.00–2.42 s — the starter, unchanged

**Observed.** Title card; a confirm press starts the attempt and the timer runs.
The character walks right, hops the step block at x 160 and clears the original
spike cluster at x 320.

**Interpretation.** Source-code fact: the jump is one fixed arc — `player.gd`
consumes a single `opportunity_consumed` per landing and there is no
variable-height branch.

**Narration.** "Sections one and two are the starter's."

**Next experiment.** None; this beat exists to establish the baseline the rest
is measured against.

---

### B04 · `run-01` 2.42–4.60 s — the character

**Observed.** Both original gaps cleared at full speed. Thrusters visible only
while off the ground; the flame is longer on the way up.

**Interpretation.** Measured, not inferred: 6.7 logical px of flame at 2.50 and
2.60 s (rising) against 3.3–3.7 px at 2.75, 2.90 and 3.00 s (apex and after).
Source-code fact: `flame := 7.0 if velocity.y < 0 else 4.0`.

**Narration.** "Now the character. The starter's had no airborne state at all."

**Next experiment.** Watch the gem rather than the thrusters on a left-facing
jump — the facing cue is the thing the first version got wrong.

---

### B06 · `run-01` 4.20–6.05 s — the bounce pad

**Observed.** The character walks onto an orange chevron block and is thrown
far higher than its own jump, landing on a platform it could not otherwise
reach.

**Interpretation.** Source-code fact: `BOUNCE_VELOCITY = -480.0` applied in
`_apply_pads()` on contact only. **Trade-off:** the pad also discards a queued
jump on the tick it fires. Without that, a jump press on the pad silently
replaces the launch one tick later and you come up short — so reliability was
bought at the cost of one input being ignored in one place.

**Narration.** "The orange pad with the chevrons is not a platform. It launches."

**Next experiment.** Hold jump across the pad and confirm the launch height is
unchanged.

---

### B08 · `run-04` 5.80–16.50 s — the cycling platform

**Observed.** The platform is solid, blinks for roughly half a second, vanishes
leaving a faint outline, and returns. Three full cycles pass while the character
stands on the deck. It then jumps and lands.

**Interpretation.** Source-code fact: 3.0 s cycle, 60% solid, derived from
`elapsed` rather than stored, so it resets with every attempt. **Trade-off:**
the warning blink costs half a second of the solid window in exchange for the
rhythm being readable at all.

**Narration.** "Three second cycle, solid for sixty percent of it… Watch the
route stop on the deck and check before it commits."

**Next experiment.** Stand on the platform and deliberately do not jump.

---

### B10 · `run-02` 7.00–13.00 s — failure and recovery

**Observed.** The character jumps toward the platform while it is absent, falls
past the bottom of the level, and reappears at the spawn point with the retry
counter at 01. It then replays the route and finishes.

**Interpretation.** The miss is the driver's decision — the input log records
`deliberate_miss` at tick 471 with `cycle_solid_left: 0.0`. The death is the
game's own fall check against `fall_y`. Nothing was disabled to cause it.
**This is a scripted route, not a human playtest**, and it says nothing about
whether a first-time player would have read the blink in time.

**Narration.** "Same jump, taken while the platform is gone. The miss is
deliberate. The death isn't."

**Next experiment.** The same miss with a human at the keys, to see whether the
blink is warning enough.

---

### B13 · `run-05` 5.60–29.50 s — prediction three, reconstructed

**Observed.** Three red spikes drawn in empty air near the bottom of the frame,
roughly 96 px below the strip they belong to. The strip above them is bare. The
`FINISH` label sits over the old finish position and the background grid stops
dead at x 960.

**Interpretation.** Source-code fact: the pre-fix hazard loop reads only
`entry[0]` and hard-codes the count, width, base and tip. The kill box is built
correctly from the rectangle, so the lethal geometry and the drawn geometry are
in different places. **Labelled as a reconstructed intermediate state** — a real
engine run of an uncommitted working tree, not a revision in history.

**Narration.** "So the prediction was: the new spikes will draw about ninety six
pixels low… That is what you are looking at."

**Next experiment.** Walk across the apparently empty ground under the floating
spikes and confirm nothing happens.

---

### B15 · `run-01` 7.45–8.95 s — the slot

**Observed.** The character hops from the left end of the strip, clears the
first spike cluster and lands in the gap between the two clusters.

**Interpretation.** 40 px between clusters, 18 px character, 22 px of landing
window. **Trade-off named in FRICTIONAL entry 13:** a full-speed jump covers
about 109 px and overshoots from anywhere standable, so the arc has to be
shortened in the air. That makes the section a test of air control rather than
of launch-point choice — more demanding than the brief described.

**Narration.** "Forty pixels between the two clusters."

**Next experiment.** Narrow the slot to 32 px and see whether it is still
landable. This is the film's Your Turn.

---

### B17 · `run-01` 8.95–10.58 s — completion

**Observed.** The completion panel: 9.1 seconds, 0 retries, "One jump. No double
jump. Unlimited retries."

**Interpretation.** The goal area is 56 px tall and a jump rises 56 px, so any
approach clearing the second cluster enters the goal before landing. The run
finishes in mid-air. That is a property of the level, not of the capture.

**Narration.** "Nine point one seconds, zero retries."

**Next experiment.** None. The honest note belongs in the verdict, not a retest.

---

## Not riffed

- **Pause/resume and manual restart** are implemented and appear in no take.
  They are logged in `coverage.json` as `implemented` with empty evidence, which
  fails the coverage check by design rather than being relabelled.
- **`run-03`** is superseded and referenced by no beat.
