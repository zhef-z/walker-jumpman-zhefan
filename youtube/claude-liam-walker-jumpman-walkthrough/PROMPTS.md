# PROMPTS — Walker Jumpman: Mind the Clock | CSYE 7270

Every prompt that appears on screen in this film, with its status. Two prompts
are shown; neither is presented as a historical transcript.

---

## B00 — the Walker prompt (cold open)

**Status: ILLUSTRATIVE RECONSTRUCTION.** This prompt was written *backwards* from
`CHANGE-BRIEF.md`, which itself was written before any code changed. It is not a
transcript of a live session, no build receipts or progress output are shown,
and the on-screen card says so: `Illustrative reconstruction — not a session
transcript`. Liam's narration states that it is a reconstruction.

> Please use Walker to convert my game design document about a small 2D
> precision platformer into a playable Godot project. The character is a
> bone-coloured automaton: a tapered three-pronged head, a teal gem that swings
> to whichever side it is facing, a ribbed collar, a cape, a belly glow, and
> thrusters that fire only while it is in the air. Extend the existing First
> Steps level past its finish with a bounce pad, an observation deck, a platform
> that blinks in and out on a three-second cycle, and a spike strip with a
> forty-pixel slot to land in. Keep the movement tuning, the collider and the
> retry rules exactly as they already are.

**Every clause traces to the brief:**

| Clause | Source |
|---|---|
| bone automaton, three-pronged head, gem reads facing, cape, belly glow, thrusters | `CHANGE-BRIEF.md` §1 |
| bounce pad, observation deck, 3 s cycling platform, spike strip with a 40 px slot | `CHANGE-BRIEF.md` §2 "Layout" and "Distances" |
| keep the tuning, the collider and the retry rules | `CHANGE-BRIEF.md` §3 "What must not change" |

The card's body text repeats the same content in the composer's output pane so a
viewer reading rather than listening gets the same claim.

---

## B21 — the Your Turn prompt

**Status: LIVE INVITATION.** A real change a viewer can make in about a minute,
chosen by the human author as the film's one concrete next improvement.

> In `first_steps.json`, move the second spike cluster from x 1384 to x 1376 so
> the slot is 32 px instead of 40. Change nothing else. Then play it — can you
> still land in there? And does the route test still pass?

**Arithmetic shown on the card, all from source:**

- second cluster `[1384, 208, 24, 16]` → `[1376, 208, 24, 16]`
- first cluster ends at x 1344, so the slot goes 40 px → **32 px**
- the character's collider is `Vector2(18, 28)`, so the landing window goes
  22 px → **14 px**
- `godot/tests/test_game.gd` asserts `complete-real-route` within 900 ticks with
  zero deaths, so the automated route is a second, independent answer

Liam discusses it rather than only reading it: the point of the experiment is
that it is the honest test of whether the section is precision or luck, and a
failing route test is itself informative.

---

## Prompts NOT shown

- No fabricated Claude session, no invented tool output, no progress spinner, no
  "build succeeded" receipt. The one composer card in the film is B00 and it is
  labelled a reconstruction.
- No prompt claims to have produced the code on screen. The code beats show real
  source from the repository at the stated revisions (`8d64a7c^` for the pre-fix
  hazard loop, `d88860e` for everything else), not model output.

## Prompts used to make the film (not shown on screen)

The reel was authored by the `godot-waikthrough` skill in `walker` mode against
this repository, demonstrating revision `d88860e`. The human supplied the title,
the feel/fun verdict sentence, and the Your Turn experiment; chose the
cause-and-effect beat; asked for the uncut full-route beat (B01A) after seeing
that the first cut had only excerpts; and requested script changes before
anything was voiced. Everything else was derived from the repository's own
records. See `BUILD-PROMPT.md`.
