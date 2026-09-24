# FRICTIONAL

Honest log of what I tried, what went wrong, and what I did about it.
Entries are in the order they happened. Where Claude or Claude Code did
something, I say so.

---

## 1. The starter changed before I touched it

**Expected:** a fresh clone would be a clean working tree.

**What happened:** `git status` showed `godot/project.godot` modified
before I had written anything. I asked Claude Code to read the diff. It
reported that opening the project in Godot 4.7.2 had rewritten the file:
`window/stretch/aspect="keep"` and the `[physics]` tick-rate pin were gone,
and the starter's header comment had been replaced with Godot's
boilerplate.

**What I checked:** I read the diff rather than resizing the window to see
the stretch change — the two dropped settings were plain in the text. The
cause was confirmed later: the file survives headless runs untouched (same
md5 before and after) and only changes once the editor has opened the
project.

**What I did:** restored both settings and the header as a separate commit
before any gameplay change, so the regression couldn't get mixed up with
my own work. — `7f19b50`

**Human / AI:** I noticed the unexpected modification and decided to chase
it and to keep it in its own commit. Claude Code read the diff and made the
edit.

---

## 2. It happened again

Later the same two settings were missing again. Same cause — the editor
rewrites the file every time it opens the project.

I decided not to keep fixing it by committing. HEAD already has the correct
version, so after each editor session I restore the file with
`git checkout -- godot/project.godot`. I didn't test whether setting Aspect
through Project Settings would make the editor keep it.

Later result (see entry 6): running the tests headless from the command
line left `project.godot` untouched, same md5. So it's the editor, not
running the project.

**Unresolved:** I still don't know whether the editor can be made to
persist the value.

---

## 3. Getting Brutalist installed on Windows

`./setup --install` pulled the Remotion dependencies and the Kokoro voice
model fine but the Python step failed. `pip` wasn't found in Git Bash, and
`python --version` printed nothing in either Git Bash or PowerShell.
`where python` showed only
`...\AppData\Local\Microsoft\WindowsApps\python.exe`, which is the
Microsoft Store stub, not a real install.

I did have Python — through Anaconda — it just wasn't on PATH. Searching
for `python.exe` found `C:\Users\lenovo\anaconda3\python.exe` (3.12.7). I
added Anaconda to PATH in `~/.bashrc`, after which `python --version`
worked and `./art --list` listed the skills, including
`godot-waikthrough`.

**Human / AI:** Claude suggested where to look; I ran the searches and
found the install.

Second failure in the same step: once Python was on PATH, pip crashed
reading requirements.txt with a GBK decode error. The file is UTF-8 and my
Windows locale is Chinese, so Python read it as GBK. PYTHONUTF8=1 fixed it,
and I added it to ~/.bashrc because Brutalist reads other UTF-8 files later.
Installing into Anaconda's base environment also upgraded numpy and
protobuf, which broke manim and some unrelated packages in base. Not fixed
yet; the film doesn't use manim.

---

## 4. Designing the character

I went through several versions before settling.

- Started with a Pokémon-style round seal — dropped it because I wanted
  something that could keep a rectangular shape and still be recognisable.
- Then a blue-and-yellow box robot. I felt it wasn't cute enough, so Claude
  drew a version with rounded corners, a mouth and an antenna. I then cut
  most of that back, because it adds code I'd have to explain and the look
  isn't what the character criteria are mainly scoring.
- Switched to a bone-coloured automaton based on a reference image I
  picked. The first attempt at matching it came out badly proportioned —
  I rejected it and went back to a simpler base.
- Over several rounds I asked for: a single eye instead of two, the small
  ball moved inside the head, a lighter pupil, shorter legs and longer
  arms, a smaller head, a tapered head, three square prongs joined into
  the head as one shape, and the eye swinging much further left/right for
  facing.

**Human / AI:** every design decision above was mine. Claude produced the
mock-ups and worked out coordinates to fit the collider.

---

## 5. Writing the change brief

The first draft of the brief used the per-tick jump numbers Claude Code
computed (56 px height, 109.3 px distance, 124 px bounce rise). I realised
I couldn't derive those on the spot if asked — they come from summing the
engine's per-frame integration. I switched to the textbook formulas
(v²/2g, 2v/g), which I can work out by hand, and noted that the engine's
real numbers come out slightly higher, so the textbook values are the
conservative side. Claude Code later confirmed the real values are higher.

I also rewrote the character section after the design changed, and asked
for the prose to be less formal. — `a0f86a3`

**Human / AI:** the level design and the three predictions are mine;
Claude drafted the English and I revised it.

---

## 6. Character implementation, first run: the suite didn't run at all

The head polygon was declared as
`const HEAD := PackedVector2Array([...])`, which GDScript rejects as not a
constant expression. The diff looked correct when I reviewed it, and
Claude Code had stated in its plan that the const form was valid. I didn't
catch it by reading; the compile error only appeared when the test suite
ran. Changed it to `var`.

Side result: the headless run left `project.godot` unchanged (same md5), so
the aspect/tick regression comes from opening the editor, not from running
the project.

Also noticed: a compile error in any depended script makes the test
harness loop on a null player forever instead of exiting. Not fixing it —
out of scope — but it's why the output ran to 107k lines.

**Human / AI:** Claude Code wrote the `const` line and the fix. I had
reviewed and approved the diff without spotting it.

Re-ran after the fix: 25 checks / 0 failures. Jump rise measured at
56.07 px against the textbook 53.33, confirming the brief's figures are the
conservative side. Route test completed in 325 ticks with all five jump
marks used.

---

## 7. First windowed look: the eye gives up facing in the air

Opened the game in the editor and looked at the character directly.

- The concave head rendered correctly — three prongs, two notches. The
  risk I'd flagged in the brief didn't happen.
- Standing, facing is obvious: the gem sits at the right or left edge of
  the head.
- Console showed only the engine start-up lines, no errors or warnings.

But when I jumped, the thrusters fired and the gem went back to the middle
of the head. In the air I couldn't tell which way I was facing.

That was my own design — I'd had the gem recentre to signal "airborne".
Playing it, I realised it throws away the facing cue at exactly the moment
the new section needs it: landing between the two spike clusters, you need
to know which way you're drifting. The other airborne cues (thrusters,
raised arms, bigger ball, brighter belly) already say "in the air" on their
own, so the gem doesn't need to.

Change: the gem keeps its facing offset in the air; only its size and
colour change.

**Human / AI:** I spotted the problem by playing and decided the fix.
Claude Code makes the edit.

**Re-test:** jumped facing right and facing left — the gem stays at that
side of the head in the air, so facing is readable throughout the jump.

---

## 8. Seeing prediction 3 happen before fixing it

I added the new level data first and left the drawing code alone, so I
could watch it fail on data it was never written for. Standing at the
right end of Ground C: the new spikes were drawn about 96 px below the
spike strip, floating in empty air, while the strip above them was bare.
The FINISH label was still hanging over Ground C, the background grid
stopped dead at x 960, and hatch marks poked out of the bottom of the
new platforms. Prediction 3 was right, including the direction and
roughly the size of the offset.

One problem in the same class couldn't be seen at all: the background
rect also stopped short of the new width, but it's the same colour as the
clear colour, so there's no seam on screen. Only reading the code found
it. Not everything wrong can be caught by playing.

**Human / AI:** I chose the order (data first, then fix) so the
prediction could be tested. Claude Code worked out what would be
visible from where I could stand.

---

## 9. Making the drawing follow the data

Hazards, background, grid, hills, finish flag and FINISH label now come
from the level data instead of fixed numbers. Claude Code checked the
regression numerically rather than by eye: it evaluated the old and new
formulas on the original level data and compared every vertex. The
original hazard's three spikes came out identical.

Clamping the hatch marks also changed the section 01 step block, which
had the same overshoot. Recorded in the brief as Revision 2.

Separately, I sent a contradictory instruction about moving the 04
labels — "move left" toward a position that was actually to the right.
Claude Code asked which I meant instead of guessing. Moved them left.

---

## 10. Bounce pad

With the pad working the level could be finished by hand for the first
time. One behaviour I hadn't anticipated: pressing jump on the pad would
have replaced the bounce with a normal jump one tick later, not enough
to reach the deck. The pad now ignores the jump button. Recorded as
Revision 3, because it touches jump-adjacent behaviour.

Checked in play: the pad looks different from a platform, the bounce
reaches the deck, jumping on the pad still bounces, spikes sit on the
strip, the flag and FINISH label are at the new finish, the level can
be completed, and sections 01 and 02 play as before.

---

## 11. The platform looked solid and wasn't

The cycling platform never blinked and always looked fully solid, but I
kept falling through it.

Cause: the level is drawn once, in _ready(). The player redraws itself
every tick, the level never does. So the picture froze at the first
frame, when the platform happened to be solid. The collision underneath
was correct the whole time — solid for 60% of each cycle — but with a
frozen picture I was stepping on at random points and dropping through
about 40% of the time with no warning.

This is the thing the course keeps pointing at: the code was right, the
physics was right, and the game was still wrong, because what the
player sees had stopped matching what the game checks. Nothing errored.

Fix: redraw the level every tick while it has a cycling platform.

**Human / AI:** I found it by playing. Claude suggested two possible
causes; Claude Code confirmed the first by reading the code. Claude Code
had checked redrawing for the player in the original implementation but
not for the level.

**Re-test:** the platform now stays solid, blinks in the last half
second, then shows only a faint outline, and repeats. I only fall
through when it's visibly gone.

---

## 12. Testing the predictions

**Prediction 1 — timing window.** Played the cycling platform
repeatedly; I didn't keep an exact count. I did have to stop on the
deck and watch the rhythm before going, so the window isn't too long.
I didn't get caught by it vanishing before I could get off, so it isn't
too short. The starting values (3 s cycle, 1.8 s solid) held.

**Prediction 2 — jumping as it vanishes.** Standing still, pressing
jump just after the platform vanished still produced a jump.
Prediction confirmed. Pressing well after it vanished dropped me, as
expected. On the buffer side, pressing jump while falling onto the
platform as it appeared didn't bounce me straight off.

Decision: keep the coyote jump off a vanished platform. The window is
0.1 s and comes right after a half-second blink warning, so it reads
as forgiving a near-miss rather than letting the player out of the
rule — you still have to be on the platform while it's solid.

**Facing on respawn.** You respawn facing whichever way you died.
Left unchanged, as decided, because retry behaviour is on my
must-not-change list.

**Other checks:** stepping off a ledge and pressing jump immediately
still jumps; pressing jump just before landing jumps on contact;
dying in the new section retries normally.

**Human / AI:** I ran these by hand. Claude wrote up my results.

---

## 13. Updating the route test

The supplied route driver was a list of five x positions where it
tapped jump while holding right forever. It couldn't stop, so it could
never wait for the cycling platform. Claude Code changed each mark into
a small record with two optional behaviours: wait (stand still until
the platform will still be solid on arrival) and hold (let go of right
partway through a jump).

The hold turned out to matter more than I expected. A full-speed jump
covers about 109 px and the spike slot is 40 px wide, so no full-speed
jump from anywhere you can stand lands in it. The route has to release
right mid-air to shorten the arc. That's the real skill section 04 asks
for: air control, not picking the right launch point. The brief said
"the distance is easy, the placement isn't"; it's more specific than
that.

The first working attempt clipped the tip of a spike by about 0.3 px.
Moving an earlier wait point 6 px left gave the slot hop enough time to
climb. Final route: 536 ticks, identical across two runs. The 900-tick
cap didn't need raising and no assertion was changed.

**Human / AI:** I set the constraints — keep zero deaths, don't weaken
anything, add a check for the new section. Claude Code designed and
tuned the driver.

---

## 14. Making the film

The approved script was far longer than the gameplay — the whole
route takes about nine seconds — so Claude Code added extra captures
and moved the source-code explanations onto animated cards.

Captures run in a real Godot window, and the game pauses when that
window loses focus. Two long takes were ruined this way without any
error. Claude Code added a check that compares each take's input log
against a headless reference run, which caught both.

The first reconstruction of prediction 3 used the level data from
8d64a7c. By then the bounce pad and cycling platform had been moved
into their own lists, which the old drawing code doesn't read, so
both were missing and the character was balanced on a ledge. Claude
flagged that this didn't match what I'd seen; I confirmed it — when I
saw the misdrawn spikes, both were still plain platforms and I was
standing on the pad. It was rebuilt with the data as it actually was
then.

Watching the first cut, I noticed there was no continuous
playthrough, only excerpts. I asked for one uncut run of the whole
route.

Reviewing the script before it was voiced, we caught one beat
stating the flame changes length while the verdict listed it as
untested, and a credits line that could read as if no human playtest
happened.

I also had Gemini review the finished film. It suggested rewriting
the git history into fewer commits to match the film's story. I
didn't: the history already shows each step as its own commit, and
rewriting it would change the hashes the film refers to.

**Human / AI:** I chose the title, the verdict, the Your Turn
experiment and the cause-and-effect beat, asked for the uncut run,
and reviewed the script. Claude Code wrote the script, captured,
rendered and compiled. Claude helped me review the script.

---

## Open
