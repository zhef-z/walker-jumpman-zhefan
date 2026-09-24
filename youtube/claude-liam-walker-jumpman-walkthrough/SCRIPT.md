# SCRIPT — Walker Jumpman: Mind the Clock | CSYE 7270

Narrator: **Liam, in for Bear** · Kokoro `am_onyx` · channel `@NikBearBrown`
Revision demonstrated: **d88860e** · Mode: `godot-waikthrough walker`
Status: **Final — signed off, voiced and rendered.**

Generated from `beat_sheet.json`, the sheet the film was built from, so
every narration line below is the text that was voiced and every label is
the text that was rendered. Beat order is film order.

Master: `exports/landscape/claude-liam-walker-jumpman-walkthrough.mp4` — 411.200 s, 3840×2160 @ 30 fps.

All gameplay is scripted-input engine capture, labelled on screen. No
burned subtitles. The final card is silent under the stock jingle.

---

## B00 — cold open · 11.90 s (from 0.00 s)

**Shot:** card · `ClaudeComposerAsk`

**topic:** WALKER JUMPMAN · GODOT WALKTHROUGH

**segment:** Mind the Clock

**greeting:** Illustrative reconstruction — not a session transcript

**Prompt shown:**

> Please use Walker to convert my game design document about a small 2D
> precision platformer into a playable Godot project.

**Narration (as voiced):**

> This is Liam, in for Bear. That prompt is a reconstruction. It was written
> back from the change brief, which was written before any code changed. It
> is not a transcript of a live session, and nothing here is a build
> receipt.

---

## B01 — what was built · 31.53 s (from 11.90 s)

**Shot:** card · `ClaudeVerdictArtifact`

**artifactTitle:** What was built

**artifactHeading:** walker-jumpman · revision d88860e

**Narration (as voiced):**

> Here is what actually exists. The starter is walker jumpman, a control and
> retry slice: three ground slabs, one spike cluster, two gaps, a finish
> flag. That is commit nine three eight seven five four two. On top of it,
> two changes. A new character, drawn entirely in code. And a second half of
> the level, five hundred and twelve more pixels of it. This is a slice, not
> a finished game. The starter's design document proposes cherries, three
> zones and sound. None of that is built, and none of it is in this film.
> What you are about to watch is revision d eight eight eight six zero e.

---

## B01A — full route · 10.60 s (from 43.43 s)

**Shot:** gameplay · `run-01` 0.00–10.58 s

**On-screen label:** `scripted input — full route, uncut`

**Narration (as voiced):**

> Before taking it apart, here's the whole route in one go — start to
> finish, no cuts, scripted input at normal speed. It takes about nine
> seconds.

---

## B02 — gameplay · 2.80 s (from 54.03 s)

**Shot:** gameplay · `run-01` 0.00–2.42 s

**On-screen label:** `scripted input · revision d88860e`

**Narration (as voiced):**

> Sections one and two are the starter's.

---

## B03 — source · 22.37 s (from 56.83 s)

**Shot:** card · `ClaudeCodeBeat`

**title:** godot/game/session.gd — the hatch clamp

**sparkLine:** geometry unchanged; one drawing in section 01 changed with it

**Narration (as voiced):**

> A step block, a spike cluster, a sixty four pixel gap, then a forty eight
> pixel gap. Every jump you see is the same height. One press, no double
> jump, no variable height. Those two sections still play the same after the
> change, with one exception I will own rather than skip. The hatch marks on
> that first step block used to poke three pixels through its underside.
> Clamping them for the new thin platforms fixed that one too. Collision did
> not move. The drawing did.

---

## B04 — gameplay · 3.90 s (from 79.20 s)

**Shot:** gameplay · `run-01` 2.42–4.60 s

**On-screen label:** `scripted input · revision d88860e`

**Narration (as voiced):**

> Now the character. The starter's had no airborne state at all.

---

## B05 — source · 23.00 s (from 83.10 s)

**Shot:** card · `ClaudeCodeBeat`

**title:** godot/features/player/player.gd — airborne is a state now

**sparkLine:** measured in run-01: flame 6.7 px rising, 3.3 px after the apex

**Narration (as voiced):**

> Its only animation was a walk cycle, and it was gated on being on the
> floor and moving, so in mid air it drew exactly like a standing idle. You
> could not tell by looking whether you were rising, falling, or standing
> still. This one fires thrusters, and the flame is longer going up than
> coming down. The gem reads facing. The first version recentred it in the
> air, which threw away the facing cue at exactly the moment the new section
> needs it. It stays put now.

---

## B06 — gameplay · 4.40 s (from 106.10 s)

**Shot:** gameplay · `run-01` 4.20–6.05 s

**On-screen label:** `scripted input · revision d88860e`

**Narration (as voiced):**

> The orange pad with the chevrons is not a platform. It launches.

---

## B07 — source · 34.97 s (from 110.50 s)

**Shot:** card · `ClaudeCodeBeat`

**title:** tuning.gd + session.gd — the pad has its own constant

**sparkLine:** CHANGE-BRIEF.md Revision 3 — the exception, written down

**Narration (as voiced):**

> Its constant is minus four hundred and eighty, against the jump's minus
> three hundred and twenty. Same gravity, so the rise goes from about fifty
> three pixels on paper, fifty six when you actually measure it, to about a
> hundred and twenty. Jump velocity itself never changed: the pad has its
> own number, and your jump is identical everywhere else. One thing the
> brief did not anticipate. Press jump while standing on the pad, and the
> ordinary jump would overwrite the launch one tick later, cutting the rise
> to something that cannot reach the deck. So on the pad, the pad wins. A
> jump request is discarded on the tick it fires. That is a deliberate
> exception, and it is written down.

---

## B08 — gameplay · 10.70 s (from 145.47 s)

**Shot:** gameplay · `run-04` 5.80–16.50 s

**On-screen label:** `scripted input · route waits three full cycles · revision d88860e`

**Narration (as voiced):**

> Three second cycle, solid for sixty percent of it. For the last half
> second it blinks, and that blink is not polish. Watch the route stop on
> the deck and check before it commits.

---

## B09 — source · 15.17 s (from 156.17 s)

**Shot:** card · `ClaudeCodeBeat`

**title:** session.gd — the cycle is derived, never stored

**sparkLine:** elapsed resets every attempt, so the rhythm is reproducible

**Narration (as voiced):**

> Without a warning, a platform that vanishes reads as the game cheating
> instead of as something you should have seen coming. It only goes when at
> least nine tenths of a second of solid time is left, because the jump
> itself takes about seven tenths, and you still have to land and get off
> again.

---

## B10 — gameplay · 6.60 s (from 171.33 s)

**Shot:** gameplay · `run-02` 7.00–13.00 s

**On-screen label:** `scripted input · deliberate miss · revision d88860e`

**Narration (as voiced):**

> Same jump, taken while the platform is gone. The miss is deliberate. The
> death isn't. It's the game's own physics.

---

## B11 — source · 14.30 s (from 177.93 s)

**Shot:** card · `ClaudeCodeBeat`

**title:** capture_driver.gd — the miss is a decision, not a cheat

**sparkLine:** run-02 input log: deliberate_miss at tick 471, cycle_solid_left 0.0

**Narration (as voiced):**

> The driver asks the game how much solid time is left, gets zero, and goes
> anyway. It falls past the kill line, the game's own retry puts it back at
> the spawn, and the retry starts the route over from the top. No lives, no
> penalty. Just another try.

---

## B12 — cause and effect · 27.73 s (from 192.23 s)

**Shot:** card · `ClaudeCodeBeat`

**title:** session.gd at 8d64a7c^ — only x came from the data

**sparkLine:** the literals matched the one original hazard by coincidence

**Narration (as voiced):**

> Before any of this worked, the change brief made a prediction, and wrote
> it down so it could be wrong. The hazard drawing read only the x
> coordinate out of the level file. How many spikes, how wide they are, and
> both the base and the tip height were fixed numbers in the code. They
> happened to match the one original hazard exactly. Not because the drawing
> followed the data, but because two independent sets of numbers agreed. The
> original spikes sit at y three hundred and twenty. The new ones sit at two
> hundred and twenty four.

---

## B13 — cause and effect · 23.90 s (from 219.97 s)

**Shot:** gameplay · `run-05` 5.60–29.50 s

**On-screen label:** `RECONSTRUCTED INTERMEDIATE STATE — not a commit · uncommitted working-tree level data + drawing code 8d64a7c^`

**Narration (as voiced):**

> So the prediction was: the new spikes will draw about ninety six pixels
> low, floating in empty air, while the strip above them stays bare, and the
> kill box, which is built properly from the rectangle, will stay exactly
> where it belongs. That is what you are looking at. Nothing threw an error.
> It compiled, it ran, and it was wrong only on screen. You would die over
> ground that looks empty, and walk unharmed through spikes that look
> lethal.

---

## B14 — source · 15.63 s (from 243.87 s)

**Shot:** card · `ClaudeCodeBeat`

**title:** session.gd at 8d64a7c — every number from the rect

**sparkLine:** regression: old vs new on the original data — 3 spikes identical

**Narration (as voiced):**

> The fix was to derive the drawing from the rectangle instead of the
> literals. And the regression check was numeric, not visual. The old and
> the new formula were both evaluated on the original level data and
> compared vertex by vertex. The original three spikes came out identical.

---

## B15 — gameplay · 2.87 s (from 259.50 s)

**Shot:** gameplay · `run-01` 7.45–8.95 s

**On-screen label:** `scripted input · revision d88860e`

**Narration (as voiced):**

> Forty pixels between the two clusters.

---

## B16 — source · 20.80 s (from 262.37 s)

**Shot:** card · `ClaudeCodeBeat`

**title:** capture_driver.gd — shortening the arc in mid-air

**sparkLine:** 40 px slot − 18 px character = a 22 px landing window

**Narration (as voiced):**

> The character is eighteen wide, so the window is twenty two. Here is what
> the brief got right in spirit and under described in fact. A full speed
> jump covers about a hundred and nine pixels. From anywhere you can
> actually stand, that overshoots the slot and puts you on the second
> cluster. The only way in is to let go of right in mid air and shorten the
> arc. So the skill this section tests is not picking a launch point. It is
> air control.

---

## B17 — gameplay · 3.20 s (from 283.17 s)

**Shot:** gameplay · `run-01` 8.95–10.58 s

**On-screen label:** `scripted input · revision d88860e`

**Narration (as voiced):**

> Nine point one seconds, zero retries.

---

## B18 — note · 15.00 s (from 286.37 s)

**Shot:** card · `ClaudeVerdictArtifact`

**artifactTitle:** The finish is 56 px tall

**artifactHeading:** first_steps.json — "finish": [1408, 168, 24, 56]

**Narration (as voiced):**

> One thing worth saying plainly. The goal area is fifty six pixels tall,
> and a jump is fifty six pixels high. So anything that clears the second
> spike cluster is inside the goal before it lands. This run finishes in mid
> air. That is the level, not a trick of the capture.

---

## B19 — verdict · 58.53 s (from 301.37 s)

**Shot:** card · `ClaudeVerdictArtifact`

**artifactTitle:** Verdict

**artifactHeading:** observed on d88860e · 26 checks, 0 failures

**Narration (as voiced):**

> Verdict. Observed working on this revision: the bounce pad, the cycling
> platform with its warning blink, the spike slot, the moved finish, failure
> and retry, and both original sections. Twenty six automated checks, zero
> failures. The route finishes in five hundred and thirty six ticks,
> identical across two runs. Defects and exceptions, stated rather than
> buried. The pad discards a jump request on the tick it fires. The hatch
> clamp changed one drawing in section one. The completion is touched in mid
> air. And the menu still says cross two gaps, clear the spikes, reach the
> flag, which describes the level before the extension, not the one you just
> watched. Not tested: whether the drawing lines up with the collider. Known
> and kept on purpose: press jump just after the platform vanishes and it
> still works. That is coyote time, a tenth of a second, arriving right
> after a half second blink. It was measured, judged, and kept. And the part
> that is not mine to judge. The designer's call on feel: the fun is in the
> two new challenges, reading the cycling platform's rhythm to time the
> jump, and landing precisely between the spikes.

---

## B20 — contributions · 23.27 s (from 359.90 s)

**Shot:** card · `ClaudeVerdictArtifact`

**artifactTitle:** Human and AI

**artifactHeading:** revision shown: d88860e

**Narration (as voiced):**

> Who did what. The design, the predictions, and every judgement about how
> it plays are Zhefan Zhang's. Claude Code wrote the implementation, checked
> the regression numerically, and drove and recorded these captures.
> Everything you have seen is scripted input, not a human playtest. Zhefan
> played every section by hand separately. That's where the recentring gem
> and the frozen platform were found. Those playtests are in the test
> report. The revision shown is d eight eight eight six zero e.

---

## B21 — your turn · 21.93 s (from 383.17 s)

**Shot:** card · `ClaudeComposerAsk`

**topic:** YOUR TURN

**segment:** Narrow the needle

**greeting:** One change. Then play it.

**Prompt shown:**

> In first_steps.json, move the second spike cluster from x 1384 to x 1376
> so the slot is 32 px instead of 40. Change nothing else.

**Narration (as voiced):**

> Your turn. Open the level file and narrow the slot from forty pixels to
> thirty two. Move the second spike cluster eight pixels left. That leaves a
> fourteen pixel window for an eighteen pixel character. Then go and find
> out whether you can still land in it. That is the one change I would make
> next here, because it is the honest test of whether this section is
> precision or luck. If the automated route stops passing, that tells you
> something too. This is Liam, in for Bear.

---

## B22 — outro · 6.10 s (from 405.10 s)

**Shot:** card · `ClaudeTitleOutro`

**title:** Walker Jumpman: Mind the Clock | CSYE 7270

**Narration:** none — silent beat.

---
