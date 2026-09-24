# SUBMISSION

**Assignment:** Assignment 1 - Extend Walker Jumpman
**Student:** Zhefan Zhang
**Project name:** walker-jumpman-zhefan
**GitHub repository/folder URL:** https://github.com/zhef-z/walker-jumpman-zhefan
**Submitted commit SHA:** stated in the Canvas submission note (a commit can't contain its own SHA)
**Game-source revision shown in the film:** `d88860e`
**Godot version and operating system:** Godot 4.7.2.stable (win64), Windows 11
**Final film URL and filename:** https://drive.google.com/file/d/12hrSlaRKc5Z-YdK2Xz9igt2dUo6oxK65/view?usp=drive_link, `claude-liam-walker-jumpman-walkthrough.mp4`
**Final film SHA-256:** `901342011a34abb816c26df6a88ef4378768d57b68d27564f5b3e5e359b8160c`

## Summary of my changes

- Replaced the starter character with a bone-coloured automaton drawn in
  code. Facing is shown by a gem that swings to the edge of the head; the
  airborne state, which the starter didn't show at all, is shown by
  thrusters, lifted arms and brighter glows. Collider and movement tuning
  unchanged.
- Extended the level from 960 to 1472 px: a bounce pad, an observation deck,
  a platform that cycles in and out with a blink warning, and a landing slot
  between two spike clusters that needs air control. Finish moved to the
  end.
- Made the level drawing follow the level data instead of fixed numbers.
- Updated the route test so it can wait and shorten a jump, and added a
  check that it lands on each new tier. 26 checks / 0 failures.

## Known limitations

- Menu text still describes the pre-extension level.
- Bounce pad discards a jump press on the tick it fires.
- Coyote jump works for 0.1 s after the cycling platform vanishes (kept on
  purpose).
- Respawn keeps the facing you died with.
- The Godot 4.7.2 editor rewrites `project.godot` on open; restore it with
  `git checkout`.
- Tested only on Windows.

Full list in README.md.

## Revisions

The film was rendered from game-source revision `d88860e`. Later commits
change only documentation and film source files, not game source.
