# SHOTLIST — Walker Jumpman: Mind the Clock | CSYE 7270

24 beats. Narration is the clock; every gameplay slot is conformed to its
narration at ratio 1.000000, with no compositor slowing or centre-cutting.
Film frame rate 30 fps; captures are native 3840×2160 at 60 fps.

`LIVE` = real engine action at normal speed. `HELD` = labelled final-frame hold
while narration finishes. `CARD` = Remotion composition.

| Beat | Kind | Source / pattern | Window | Narration | Live | Held |
|---|---|---|---|---|---|---|
| B00 | CARD | ClaudeComposerAsk | — | 11.88 s | — | — |
| B01 | CARD | ClaudeVerdictArtifact | — | 31.52 s | — | — |
| B01A | GAMEPLAY | `run-01` **uncut** | 0.00–10.58 | 10.60 s | 10.58 | 0.02 |
| B02 | GAMEPLAY | `run-01` | 0.00–2.42 | 2.80 s | 2.42 | 0.38 |
| B03 | CARD | ClaudeCodeBeat — hatch clamp | — | 22.34 s | — | — |
| B04 | GAMEPLAY | `run-01` | 2.42–4.60 | 3.90 s | 2.18 | 1.72 |
| B05 | CARD | ClaudeCodeBeat — airborne state | — | 22.98 s | — | — |
| B06 | GAMEPLAY | `run-01` | 4.20–6.05 | 4.40 s | 1.85 | 2.55 |
| B07 | CARD | ClaudeCodeBeat — BOUNCE_VELOCITY | — | 34.96 s | — | — |
| B08 | GAMEPLAY | `run-04` | 5.80–16.50 | 10.70 s | 10.70 | 0.00 |
| B09 | CARD | ClaudeCodeBeat — cycle derivation | — | 15.15 s | — | — |
| B10 | GAMEPLAY | `run-02` | 7.00–13.00 | 6.60 s | 6.00 | 0.60 |
| B11 | CARD | ClaudeCodeBeat — deliberate miss | — | 14.40 s | — | — |
| B12 | CARD | ClaudeCodeBeat — pre-fix hazard loop | — | 27.73 s | — | — |
| B13 | GAMEPLAY | `run-05` **reconstruction** | 5.60–29.50 | 23.90 s | 23.90 | 0.00 |
| B14 | CARD | ClaudeCodeBeat — fixed hazard loop | — | 15.62 s | — | — |
| B15 | GAMEPLAY | `run-01` | 7.45–8.95 | 2.87 s | 1.50 | 1.37 |
| B16 | CARD | ClaudeCodeBeat — shortening the arc | — | 20.80 s | — | — |
| B17 | GAMEPLAY | `run-01` | 8.95–10.58 | 3.20 s | 1.63 | 1.57 |
| B18 | CARD | ClaudeVerdictArtifact — 56 px goal | — | 15.00 s | — | — |
| B19 | CARD | ClaudeVerdictArtifact — Verdict | — | 58.53 s | — | — |
| B20 | CARD | ClaudeVerdictArtifact — Human and AI | — | 23.08 s | — | — |
| B21 | CARD | ClaudeComposerAsk — Your Turn | — | 21.93 s | — | — |
| B22 | CARD | ClaudeTitleOutro | — | silent | — | — |

**Totals.** Live action 60.76 s · labelled hold 8.19 s · narration ≈ 399 s.
Held frames are 2% of the film.

B01A is the continuous playthrough: the whole of `run-01` start to finish, no
cuts, at normal speed. Its narration is shorter than the action, so the audio is
padded with silence rather than the gameplay being stretched. The 0.02 s tail is
frame alignment, not a held frame, and is not labelled as one.

## On-screen labels (burned, bottom-left of the play area)

| Beats | Label |
|---|---|
| B01A | `scripted input — full route, uncut` |
| B02, B04, B06, B15, B17 | `scripted input · revision d88860e` |
| B08 | `scripted input · route waits three full cycles · revision d88860e` |
| B10 | `scripted input · deliberate miss · revision d88860e` |
| B13 | `RECONSTRUCTED INTERMEDIATE STATE — not a commit · uncommitted working-tree level data + drawing code 8d64a7c^` |
| any held segment | `HELD FRAME - narration continues` (red, appears only during the hold) |

B00 carries `Illustrative reconstruction — not a session transcript` inside the
composition. No burned subtitles anywhere; the outro card is silent under the
stock jingle.

## Ordering rationale

Gameplay and explanation alternate deliberately. Source-code facts sit on
`ClaudeCodeBeat` cards showing the actual lines, so nothing is narrated over a
frozen game, and the ACTUAL-CODE LAW is satisfied with real trimmed source
rather than pseudocode. The two cause-and-effect beats (B12 → B13 → B14) run
pre-fix code, the reconstructed failure, then the fix.
