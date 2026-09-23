# CHANGE-BRIEF

**Project:** walker-jumpman-zhefan
**Starter:** walker-jumpman (nikbearbrown)
**Engine:** Godot 4.7.2.stable (win64), Windows
**Baseline:** 7f19b50
**Author:** Zhefan Zhang

Written before I changed anything. The predictions in section 4 are the
originals. Whatever I learn later goes at the bottom under Revisions — I'm not
going back to edit this so the guesses look better than they were.

---

## 1. Character

I'm replacing the starter's humanoid with a bone-coloured automaton: a small
tapered head with three square prongs on top, a single teal gem set into the
face, a dark ribbed collar, a blue cape draped over the shoulders down to a
point, a large pale glow at the belly, thin clawed arms hanging at its sides,
and thrusters that fire out from under it in the air.

It's a different silhouette from the starter in every direction — narrow head
over a wide caped body, where the starter is a plain rectangular torso — and
it's still only rectangles, circles and two polygons, so there's nothing in it
I can't account for.

### The airborne thing

Reading `_draw()` first turned up something I didn't expect. The starter has no
airborne visual at all. The only state-driven change is the walk `stride`, and
it's gated on being on the floor and moving, so in mid-air the character draws
exactly like a standing idle. You can't tell from looking whether you're
jumping, falling, or standing still.

So the thrusters aren't decoration — they fill in a state that was never there.
The flame is longer while rising and shorter while falling, which also tells
you which half of the arc you're in. That matters in my new section, where
where you land is the point.

### Reading the facing

The starter shows facing with a small eye and pupil that shift a few pixels.
At the size this thing renders, I didn't trust that. The gem is the largest
feature on the character, so I'm swinging it almost to the edge of the head
instead of nudging it — at either extreme it nearly touches the side. The
small ball at the top of the head shifts with it. Two cues, both driven by the
same sign flip, so there's no way for them to disagree.

Nothing else mirrors. Head shape, collar, cape, arms and legs are symmetric
and identical in both directions, which means there is no left-facing layout
that can be subtly wrong while the right-facing one looks fine.

### Reading the airborne state

Five things change at once: the gem recentres and grows, the small ball grows,
the belly glow brightens, the arms lift, and the thrusters appear. All of them
are colour or size changes on shapes that already exist — no geometry is
rebuilt, so there's no second layout to get wrong.

I'm using five cues rather than one because the sprite is small and I'd rather
over-signal than find out during playtest that a single cue disappears at
640×360.

### Collider

18×28 box, origin at the feet. I'm not touching it. Everything except the
flame sits inside it:

- the starter's belt band is drawn wider than the box and overhangs slightly
  on each side; the widest parts of the automaton are the head prongs and the
  arms, and both stop at the edge
- the starter's walk animation swings its legs below the box, so they clip
  visibly through the floor; mine lift upward instead and never cross it

So the new drawing sits inside the collider where the starter's did not.
I checked this by reading the rect coordinates in the existing `_draw()`
rather than by eye.

**One thing I'm changing on purpose:** the thruster flame draws below the
collider when airborne. It's a `_draw()` effect, no body, no physics. The
starter already draws outside its own box in two places, so it's not a new
kind of mismatch — but allowed isn't the same as reads well, so I'll judge it
by playing rather than by pointing at precedent. The test is whether jumping
off a ledge feels the same as before.

### One risk I already know about

The head is a single polygon with three prongs on top, which makes it concave
— there are two notches in the outline. Godot triangulates concave polygons
automatically and it usually works, but it isn't guaranteed. If it comes out
wrong I'll see it immediately: a missing chunk or a filled-in notch. The
fallback is to split it into a convex head plus three rects, which looks
identical and is what I'd do rather than fight the triangulator.

I'm noting it here because it's the sort of thing that compiles, runs, throws
no error, and is only wrong on screen.

---

## 2. Level extension

### What the new bit asks of you

Both starter sections test the same thing: can you clear a gap. The hardest
jump in the whole level is the 64 px gap at x 448, which is roughly 60% of
what the character can actually reach. Nothing in the starter gets near the
limits.

I'm keeping every distance at or under that same 60% and changing what you
have to think about instead.

**Timing.** A platform that blinks in and out. You land on a deck first, watch
a full cycle to learn the rhythm, and go when it's solid and will stay solid
long enough to land, settle and jump again. The jump itself is a distance you
already cleared in section 01. Reading the cycle is the skill.

**Precision.** A strip with spikes on both sides and a 40 px slot between them.
You're 18 px wide, so you have a 22 px window to land in. The distance is easy.
The placement isn't.

I want the difficulty to come from those two things, not from widening a gap
until it's nearly unjumpable. That would be the lazy version and it would make
the original route feel inconsistent with the new one.

### Layout

Level width goes 960 → 1472. `fall_y` stays 430. The three original ground
slabs and everything on them stay exactly as they are, so the original route is
untouched and is the only way in.

Past the end of Ground C: a bounce pad, up onto an observation deck, a 64 px
gap to the cycling platform, a 48 px gap to the spike strip, through the slot,
and onto the relocated finish.

Three new landings. Two of them are jumps the player has already proven they
can make; the third needs the bounce pad.

### Distances

Working from the values in `tuning.gd` — speed 160, jump velocity 320,
gravity 960:

- jump height `v² / 2g = 320² / 1920 ≈ 53 px`
- airtime `2v / g = 2 × 320 / 960 ≈ 0.67 s`
- horizontal reach `160 × 0.67 ≈ 107 px`, origin to origin

The engine integrates per physics tick rather than continuously, so the real
numbers come out slightly above these. I'm using the textbook values because
they're the conservative end — anything that clears on paper clears in the
game with a little room spare.

| Jump | Demand | Versus the starter |
|---|---|---|
| Ground C onto the bounce pad | 16 px rise | same as the starter's step block |
| Bounce pad up to the deck | 80 px rise | bounce gives ~120 px |
| Deck to cycling platform | 64 px gap | 60% of reach — the starter's hardest jump |
| Cycling platform to spike strip | 48 px gap | 45% of reach — the starter's second gap |
| Over the first spikes into the slot | ~49 px | easy distance, tight landing |

Nothing above what the starter already asks for.

### Bounce pad

Its own constant, applied only on contact with the pad. `jump_velocity`
doesn't change, so your jump is identical everywhere else. At 480 the rise
works out to `480² / 1920 = 120 px`, which clears the 80 px I need with room
on the way up, and the longer airtime carries me across horizontally as well.

### Cycling platform

Starting at a 3 second cycle, solid about 60% of it. I'm deriving the state
from elapsed time and a phase offset instead of keeping a timer, so it stays
correct through restarts without any reset code.

1.8 s solid is a guess based on needing maybe half a second to a second to land
and set up. I expect to move it — see prediction 1.

I also want a flicker in the last half second before it goes. That's not
polish. Without a warning, disappearing reads as the game cheating instead of
as something you should have seen coming.

### What has to follow the widening

Camera clamp, background rect, grid bounds, finish flag and the FINISH label
all have to move with the data, and several of them are fixed numbers in
`session.gd` rather than values read from the level file, so they won't follow
on their own. The hazard drawing is the worst of these — see prediction 3.

Camera y is locked at 180 and the visible band is 0–360. My new platforms sit
at 208–224, so camera y is fine as is.

### Failing

Under the new section is empty, so a missed landing or a spike hit falls past
`fall_y` and hits the existing retry. No new death or respawn code.

---

## 3. What must not change

- **Controls** — A/D and arrows, Space, R, Esc, Enter. Nothing added, nothing
  remapped.
- **Movement and jump tuning** — every value in `tuning.gd` as is.
- **Collision** — the player's collider keeps its shape, size, offset, layer
  and mask.
- **Retry** — what kills you, where you come back, what resets and what
  doesn't.
- **Pause** — trigger and resume.
- **Completion** — overlapping the goal area, the completion panel, elapsed
  time, retry count, Enter to replay.
- **The rule on screen** — "One jump. No double jump. Unlimited retries." has
  to stay true.
- **Coyote time and jump buffering** — both 6 ticks. Easy to break without
  noticing and no automated test covers them. I'll check by stepping off a
  ledge and pressing jump immediately, and by pressing jump just before
  landing.
- **Both failure routes** — hitting a hazard plays an error beat before the
  reset; falling reports a missed landing. Different messaging, both need to
  keep it. My new section triggers both.
- **The original route** — sections 01 and 02 stay geometrically identical and
  fully playable.

### Three things that brush against that list

1. **The bounce pad** gives you upward velocity you can't produce yourself. Own
   constant, only fires on pad contact, so jumping anywhere else is unchanged.
   I'll re-run every original jump after adding it to confirm.
2. **The flame** draws below the collider. No body, no physics.
3. **The finish moves.** Required by the assignment. The original sections are
   still the path to it.

---

## 4. What I think will go wrong

### 1. I get the cycling platform's timing wrong

There's a window here and I doubt I'll hit it first try.

Too short and someone who read the rhythm right and jumped at the right moment
still fails, because they can't land, steady themselves, aim and jump again
before it goes. That reads as the game cheating, and it's the worse of the two.

Too long and there's no challenge left. The platform is effectively always
there, you jump whenever, and the section collapses back into being another
gap — which is the thing I just said I was trying to avoid.

**How I'll check.** Ten attempts in a row, writing down for each one which of
three things happened: I mistimed it, or it vanished while I was standing on it
before I could get off, or I made it. Too many of the second means it's too
short. If I clear it nearly every time without ever having to wait and watch,
it's too long. Then I'll add the flicker and run the same ten again — if the
failure rate drops, the problem was readability; if it doesn't, it's the
duration.

Separately: stand on it and deliberately don't jump. It should drop me and run
the normal retry. I'll watch the console while doing that, because switching a
collision shape off in the middle of a physics frame is the kind of thing that
throws an error rather than just looking wrong.

### 2. Jumping right as the platform disappears

Coyote time is 6 ticks. It was written for walking off solid ground. The
cycling platform creates something the starter never had: you're standing still
and the ground stops existing under you.

So what happens if you press jump right as it goes? I think it works — you
launch off a platform that isn't there any more and isn't drawn any more.
Whether that's forgiving or whether it makes the game contradict its own rule
isn't something reading the code will tell me.

The other end of the same window is worth watching too. Jump buffering is also
6 ticks, so a jump pressed while falling toward the platform could fire the
instant it appears, bouncing you straight off and skipping the land-and-aim
beat the section is built around.

**How I'll check.** Three cases, five attempts each: press before it goes,
press just after, press well after. Standing still each time so timing is the
only variable. Write down what happens, not what the constant implies. For the
buffer case, spam jump while falling toward it and see whether a landing ever
gets skipped.

Then I have to pick one and say so. Either it's forgiving and I keep it on
purpose, or it misrepresents the rule and I turn coyote off for this platform
type — and if I do that, it's a change to collision-adjacent behaviour, so it
gets its own justification and its own test instead of riding along with the
level work.

### 3. The new spikes draw in the wrong place

I want this on record before I touch anything.

The hazard drawing in `session.gd` only uses the x from the level data. How
many spikes, how wide, and both the base and tip heights are written into the
code as fixed numbers.

The existing hazard happens to match those numbers exactly — three spikes, 8 px
each, base 320, tip 304. So right now the drawn spikes and the kill box sit on
top of each other and it all looks fine. But that's a coincidence between two
independent sets of numbers, not the drawing following the data.

My new spikes sit higher, on the raised strip. So I expect them drawn down at
the old height, roughly 96 px below where they actually are, while the trigger
— which is built properly from the rect — stays correct. Nothing will error. It
will compile and run. I'll die in mid-air over ground that looks empty, and
walk unharmed through spikes that look lethal.

Same reason, four more places: the background only covers to about x 1400 and
my level ends at 1472; the grid stops at the old width; the flag pole is drawn
at a fixed height that ignores the finish rect; the FINISH label is a fixed
position and won't follow the moved finish.

**How I'll check.** For each hazard and the finish, compare the x and y in the
level file against where it actually shows up, one at a time instead of
eyeballing the whole level. Then two directed tests: walk slowly across the
ground that looks empty near the new spikes and confirm nothing kills me, and
walk into each drawn spike and confirm it does. Then scroll right and check the
background and grid still reach the end.

The fix is to derive these from the rect, not to swap fixed numbers for
different fixed numbers. My regression check: the original hazard has to draw
identically afterwards, same three spikes, same height. If it moves, my formula
is wrong.

---

## 5. Known risk: the route test

Not about my change, but it'll shape the verification work, so it's here before
I start.

`route_driver.gd` doesn't assert anything. It's a short input generator that
holds right forever and taps jump at each of five hard-coded world x positions.
The actual assertion is in `test_game.gd` — reach COMPLETE with zero deaths
inside 900 physics ticks.

Extending past the last mark breaks it, in ways worth naming now:

- once it runs out of marks it never jumps again, so it walks into the first
  new gap and dies
- the marks are absolute coordinates hand-tuned to the current edges, so
  shifting anything earlier invalidates everything after it
- its movement axis is pinned to "right" and never released, so it can't wait —
  which is exactly what the cycling platform needs
- the 900-tick cap has room today (the current run finishes in about 350) but
  waiting out a full cycle eats into it

So it's a replay of one specific solution, not a solver. I'll need to extend
the marks and give it some way to wait, and say in TEST-REPORT.md what changed
and what new check covers the extension. I'm not deleting a failing assertion
or relaxing the zero-deaths condition to get a green run.

---

## Revisions

*(appended as I go — everything above stays as originally written)*

### Revision 1 — the gem no longer recentres in the air

Section 1 says five cues change when airborne, including the gem moving
back to the centre. Playing it, that removed the facing cue exactly when
the new section needs it — landing between the spike clusters, you need
to know which way you're drifting. The gem now keeps its facing offset in
the air and only changes size and colour.

That takes the airborne cues from five to four: gem size and colour, ball
size, belly glow, raised arms, thrusters. The thrusters are the loudest by
far, so the airborne state still reads clearly. The original reasoning
was redundancy because the sprite is small; in practice, facing in the
air mattered more than one extra airborne cue.

### Revision 2 — hatch clamp also touches section 01

Section 3 says sections 01 and 02 stay geometrically identical. They
do — no solid moved and collision is unchanged. But clamping the
hatch marks so they stop poking out of 16 px platforms also fixed
the same pre-existing overshoot on the section 01 step block, so
there is one visible drawing change inside the original route. I
kept it rather than special-case one platform by position.

### Revision 3 — the bounce pad ignores the jump button

On the pad you always get the bounce, never a normal jump. Without
this, pressing jump on the pad overwrote the bounce velocity with the
ordinary jump one tick later, cutting the rise from about 120 px to
about 53 px — not enough to reach the deck. Whether you reached the
deck would then depend on whether you happened to press jump. This
touches jump-adjacent state, which section 3 lists as must-not-change,
so I'm stating it: jump_velocity is unchanged, coyote and buffering
are unchanged everywhere else, and the only difference is that a jump
request is discarded on the tick the pad fires.

### Revision 4 — how the predictions came out

Prediction 1 did not happen: the starting cycle held — I had to wait
for it, and it never vanished before I could get off. Prediction 2
happened as predicted: a jump pressed just after the platform vanishes
still succeeds. I kept it on purpose; reasoning in FRICTIONAL entry 12.
Prediction 3 happened as predicted, roughly 96 px low, and was fixed
by deriving the drawing from the level data.
