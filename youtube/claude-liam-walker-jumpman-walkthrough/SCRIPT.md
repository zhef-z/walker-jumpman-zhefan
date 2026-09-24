# SCRIPT — Walker Jumpman: Mind the Clock | CSYE 7270

Narrator: **Liam, in for Bear** · Kokoro `am_onyx` · channel `@NikBearBrown`
Revision demonstrated: **d88860e** · Mode: `godot-waikthrough walker`
Status: **DRAFT — awaiting human sign-off. No audio generated.**

All gameplay is scripted-input engine capture, labelled on screen. No burned
captions. Final card carries no narration.

---

## B00 — ClaudeComposerAsk (cold open)

**On-screen label:** `Illustrative reconstruction from CHANGE-BRIEF.md — not a session transcript`

**Prompt shown in the composer:**

> Please use Walker to convert my game design document about a small 2D
> precision platformer into a playable Godot project. The character is a
> bone-coloured automaton: a tapered three-pronged head, a teal gem that swings
> to whichever side it is facing, a ribbed collar, a cape, a belly glow, and
> thrusters that fire only while it is in the air. Extend the existing First
> Steps level past its finish with a bounce pad, an observation deck, a platform
> that blinks in and out on a three-second cycle, and a spike strip with a
> forty-pixel slot to land in. Keep the movement tuning, the collider and the
> retry rules exactly as they already are.

**Narration:**

> This is Liam, in for Bear. That prompt is a reconstruction — it was written
> back from the change brief, which was written before any code changed. It is
> not a transcript of a live session, and nothing here is a build receipt.

---

## B01 — What was built

**Narration:**

> Here is what actually exists. The starter is walker-jumpman — a control and
> retry slice: three ground slabs, one spike cluster, two gaps, a finish flag.
> That is commit nine-three-eight-seven-five-four-two.
>
> On top of it, two changes. A new character, drawn entirely in code. And a
> second half of the level — five hundred and twelve more pixels of it.
>
> This is a slice, not a finished game. The starter's design document proposes cherries,
> three zones and sound. None of that is built, and none of it is in this film.
> What you are about to watch is revision d-eight-eight-eight-six-zero-e.

---

## B02 — The starter, unchanged · `run-01` 0.00–4.30 s

**Narration:**

> Sections one and two are the starter's. A step block, a spike cluster, a
> sixty-four pixel gap, then a forty-eight pixel gap. Every jump you see is the
> same height — one press, no double jump, no variable height.
>
> Those two sections still play the same after the change, with one exception I
> will own rather than skip: the hatch marks on that first step block used to
> poke three pixels through its underside. Clamping them for the new thin
> platforms fixed that one too. Collision did not move. The drawing did.

---

## B03 — The character · `run-01` 0.00–2.42 s (inset)

**Narration:**

> The starter's character had no airborne state at all. Its only animation was a
> walk cycle, and it was gated on being on the floor and moving — so in mid-air
> it drew exactly like a standing idle. You could not tell by looking whether you
> were rising, falling, or standing still.
>
> This one fires thrusters, and the flame is longer going up than coming down.
> The gem reads facing. First version recentred it in the air, which threw away
> the facing cue at exactly the moment the new section needs it. It stays put now.

---

## B04 — Bounce pad · `run-01` 5.10–6.53 s

**Narration:**

> The orange pad with the chevrons is not a platform. It launches.
>
> Its constant is minus four hundred and eighty, against the jump's minus three
> hundred and twenty. Same gravity, so the rise goes from about fifty-three
> pixels on paper — fifty-six when you actually measure it — to about a hundred
> and twenty. Jump velocity itself never changed: the pad has its own number, and
> your jump is identical everywhere else.
>
> One thing the brief did not anticipate. Press jump while standing on the pad
> and the ordinary jump would overwrite the launch one tick later, cutting the
> rise to something that cannot reach the deck. So on the pad, the pad wins — a
> jump request is discarded on the tick it fires. That is a deliberate exception,
> and it is written down.

---

## B05 — Cycling platform · `run-01` 6.53–7.35 s

**Narration:**

> Three second cycle, solid for sixty percent of it. For the last half second it
> blinks, and that blink is not polish. Without a warning, a platform that
> vanishes reads as the game cheating instead of as something you should have
> seen coming.
>
> Watch the route stop on the deck and wait. It only commits when at least
> nine tenths of a second of solid time is left, because the jump itself takes
> about seven tenths, and you still have to land and get off again.

---

## B06 — Failure and recovery · `run-02` 7.85–10.13 s

**On-screen label:** `scripted input — deliberate miss`

**Narration:**

> Same jump, taken while the platform is gone.
>
> The miss is deliberate. The death isn't — it's the game's own physics. The
> driver asks the game how much solid time is left, gets zero, and goes anyway.
> It falls past the kill line, the game's own retry puts it back at the spawn,
> and it runs the whole route again from the top. No lives, no penalty — just
> another try.

---

## B07 — Cause and effect: prediction three · `run-03` 6.00–11.50 s

**On-screen label:** `RECONSTRUCTED INTERMEDIATE STATE — not a commit. Level data from 8d64a7c, drawing code from 8d64a7c^`

**Narration:**

> Before any of this worked, the change brief made a prediction, and wrote it
> down so it could be wrong.
>
> The hazard drawing read only the x coordinate out of the level file. How many
> spikes, how wide they are, and both the base and the tip height were fixed
> numbers in the code. They happened to match the one original hazard exactly —
> not because the drawing followed the data, but because two independent sets of
> numbers agreed.
>
> The original spikes sit at y three hundred and twenty. The new ones sit at two
> hundred and twenty-four. So the prediction was: the new spikes will draw about
> ninety-six pixels low, floating in empty air, while the strip above them stays
> bare — and the kill box, which is built properly from the rectangle, will stay
> exactly where it belongs.
>
> That is what you are looking at. Nothing threw an error. It compiled, it ran,
> and it was wrong only on screen. You would die over ground that looks empty and
> walk unharmed through spikes that look lethal.
>
> The fix was to derive the drawing from the rectangle instead of the literals.
> And the regression check was numeric, not visual: the old and the new formula
> were both evaluated on the original level data and compared vertex by vertex.
> The original three spikes came out identical.

---

## B08 — Thread the needle · `run-01` 8.07–8.78 s

**Narration:**

> Forty pixels between the two clusters. The character is eighteen wide, so the
> window is twenty-two.
>
> Here is what the brief got right in spirit and under-described in fact. A
> full-speed jump covers about a hundred and nine pixels. From anywhere you can
> actually stand, that overshoots the slot and puts you on the second cluster.
> The only way in is to let go of right in mid-air and shorten the arc.
>
> So the skill this section tests is not picking a launch point. It is air
> control.

---

## B09 — Completion · `run-01` 8.78–10.58 s

**Narration:**

> Nine point one seconds, zero retries.
>
> One thing worth saying plainly. The goal area is fifty-six pixels tall, and a
> jump is fifty-six pixels high. So anything that clears the second spike cluster
> is inside the goal before it lands. This run finishes in mid-air. That is the
> level, not a trick of the capture.

---

## B10 — Verdict

**Narration:**

> Verdict.
>
> Observed working on this revision: the bounce pad, the cycling platform with
> its warning blink, the spike slot, the moved finish, failure and retry, and
> both original sections. Twenty-six automated checks, zero failures. The route
> finishes in five hundred and thirty-six ticks, identical across two runs.
>
> Defects and exceptions, stated rather than buried: the pad discards a jump
> request on the tick it fires. The hatch clamp changed one drawing in section
> one. The completion is touched in mid-air. And the menu still says "cross two
> gaps, clear the spikes, reach the flag" — which describes the level before the
> extension, not the one you just watched.
>
> Not tested: whether the drawing lines up with the collider.
>
> Known and kept on purpose: press jump just after the platform vanishes and it
> still works. That is coyote time — a tenth of a second, arriving right after a
> half-second blink. It was measured, judged, and kept.
>
> And the part that is not mine to judge. The designer's call on feel: the fun is
> in the two new challenges — reading the cycling platform's rhythm to time the
> jump, and landing precisely between the spikes.

---

## B11 — Contributions and revision

**Narration:**

> Who did what.
>
> The design, the predictions, and every judgement about how it plays are Zhefan
> Zhang's. Claude Code wrote the implementation, checked the regression
> numerically, and drove and recorded these captures.
>
> Everything you have seen is scripted input, not a human playtest. I played
> every section by hand separately — that's where the recentring gem and the
> frozen platform were found. Those playtests are in the test report. The
> revision shown is d-eight-eight-eight-six-zero-e.

---

## B12 — Your Turn

**Prompt shown:**

> In `first_steps.json`, move the second spike cluster from x 1384 to x 1376 so
> the slot is 32 pixels instead of 40. Change nothing else. Then play it — can
> you still land in there? And does the route test still pass?

**Narration:**

> Your turn. Open the level file and narrow the slot from forty pixels to
> thirty-two — move the second spike cluster eight pixels left. That leaves a
> fourteen pixel window for an eighteen pixel character.
>
> Then go and find out whether you can still land in it. That is the one change I
> would make next here, because it is the honest test of whether this section is
> precision or luck. If the automated route stops passing, that tells you
> something too.
>
> This is Liam, in for Bear.

---

## B13 — Regular outro

No narration. `ClaudeTitleOutro`, title **Walker Jumpman: Mind the Clock | CSYE 7270**,
handle `@NikBearBrown`, one crisp-safe mascot below the handle, no subline,
slug-seeded stock jingle. No gameplay audio.
