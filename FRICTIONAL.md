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

**What I checked:** [fill in — e.g. whether you resized the window to see
the stretch change, or just read the diff]

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

## Open

- **Facing on respawn.** Claude Code pointed out that `reset_at()` resets
  velocity and jump state but not `facing`, so if you die moving left you
  respawn facing left. With the starter's tiny pupil shift you'd never
  notice; with the gem swinging to the edge of the head it'll be obvious. I
  decided not to change it, because retry behaviour is on my
  must-not-change list. Still need to see it in play and decide whether
  it reads as a bug.
