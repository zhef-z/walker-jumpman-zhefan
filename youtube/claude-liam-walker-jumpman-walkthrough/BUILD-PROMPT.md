# BUILD-PROMPT — Walker Jumpman: Mind the Clock | CSYE 7270

How this reel was built, so it can be rebuilt.

**Skill:** `godot-waikthrough` with the `walker` modifier
**Subject:** `E:/7270/walker-jumpman-zhefan`, game revision **d88860e**
**Output:** native 4K landscape, 3840×2160 @ 30 fps
**Voice:** Liam in for Bear — Kokoro `am_onyx`, local, free

## The request

Make a walkthrough film of a student extension to `walker-jumpman` that:

1. identifies the starter, the character concept and the level extension;
2. shows the actual modified game being played — the new landings, at least one
   genuine failure and recovery, and a completion;
3. explains at least one cause-and-effect link between a source change and what
   happens on screen (prediction 3: the hazard drawing read only `x` from the
   level data, so the new spikes drew ~96 px low);
4. states what was tested, what remains uncertain, and one concrete next
   improvement;
5. identifies human and AI contributions and the revision shown.

Plus the walker bookends — reconstructed Walker prompt, what-was-built summary,
Verdict, Your Turn, regular outro. Any reconstructed interface view,
scripted-input capture or held frame must be labelled. No faked completion.

## Human inputs

- **Title:** `Walker Jumpman: Mind the Clock | CSYE 7270`
- **Feel/fun verdict**, quoted verbatim and attributed on screen: *"The fun is in
  the two new challenges: reading the cycling platform's rhythm to time the
  jump, and landing precisely between the spikes."*
- **Your Turn:** narrow the spike slot from 40 px to 32 px and see whether it is
  still landable — also used as requirement 4's next improvement.
- Script sign-off before any audio was generated, with five corrections applied.
- The correction that the prediction-3 reconstruction had to use the
  **uncommitted working-tree** level data, not `8d64a7c`'s committed JSON.

## Pipeline

```bash
# 1. capture — isolated project copies, never the repo's own godot/
godot --path <capture-copy> --write-movie capture/run-NN.avi \
      --fixed-fps 60 --quit-after N --resolution 3840x2160

# 2. verify every take against a headless reference (the gate)
#    input logs must match action-for-action and position-for-position

# 3. audio is the clock
python3 runtime/scripts/generate_audio_kokoro.py <reel>

# 4. conform each gameplay slot to its narration, ratio 1.000000
#    live action at normal speed; labelled final-frame hold for any surplus

# 5. cards
python3 runtime/scripts/remotion_scenes.py <reel>

# 6. master
python3 runtime/scripts/compile.py <reel> --height 2160 --fps 30 \
        --out <reel>/exports/landscape
```

## Environment notes for a rebuild

- `ffmpeg`/`ffprobe` must be on PATH (Gyan.FFmpeg 9.0.2 here).
- `python3` must resolve to a real interpreter. Anaconda ships only
  `python.exe`; a `python3.exe` copy was added alongside it.
- **`runtime/scripts/remotion_scenes.py` cannot run on Windows as written.** It
  calls `subprocess.run(["npx", ...])`, and `npx` is `npx.CMD`; `CreateProcess`
  only appends `.exe`, so the call raises WinError 2. `shutil.which("npx")`
  resolves it correctly and `shutil` is already imported, so the fix is one
  line. The toolkit was **not** modified — the render was driven through an
  in-memory patch (`scratchpad/run_remotion.py`) that rewrites a bare `npx` to
  its resolved path. Report upstream.
- `manim` is broken in this environment (scipy built against numpy 1.x vs numpy
  2.2.6). No Manim beats are used; the film needs none.

## Deliberate choices worth knowing

- **Gameplay is scripted input, never a human playtest**, and says so on screen
  and in `coverage.json`. The driver feeds real `InputEventAction`s and writes
  nothing to the game.
- **Explanation lives on cards, not over frozen gameplay.** An earlier cut had
  215 s of held frames against 20 s of action. Source-code facts moved to
  `ClaudeCodeBeat` cards showing real trimmed source; live action is now 50.18 s
  against 8.19 s of labelled hold.
- **`coverage.json` fails on purpose.** Pause/resume and manual restart are
  implemented and shown in no take, so they are recorded as `implemented` with
  empty evidence rather than relabelled `planned`. The film makes no
  completeness claim.
