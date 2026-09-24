extends Node
## Capture harness entry point. Instantiates the REAL main scene (game/main.tscn)
## untouched and attaches the input-only driver beside it. Nothing in the game's
## own code is modified for capture; this scene only exists in the throwaway
## capture copy of the project.
##
## Environment:
##   WALKER_CAPTURE_MODE=fail   run the deliberate-miss variant
##   WALKER_CAPTURE_LOG=<path>  where to write the JSONL input log
##   WALKER_CAPTURE_MAX=<int>   hard frame cap (default 3000)

const Driver = preload("res://capture/capture_driver.gd")
const Game = preload("res://game/session.gd")

var game: Node2D
var driver: Node
var tail: int = -1
var frames: int = 0
var max_frames: int = 3000

func _ready() -> void:
	var cap := OS.get_environment("WALKER_CAPTURE_MAX")
	if cap != "":
		max_frames = int(cap)
	game = (load("res://game/main.tscn") as PackedScene).instantiate()
	# HARNESS ACCOMMODATION, disclosed in CAPTURE.md. `test_mode` gates exactly one
	# thing in session.gd: _on_focus_lost() auto-pausing the game. A windowed Movie
	# Maker recording runs for minutes on a normal desktop, and a stray focus change
	# silently paused two takes mid-capture. Pause/resume itself is untouched and
	# still reachable through Esc. No gameplay value changes.
	game.test_mode = true
	add_child(game)
	driver = Driver.new()
	driver.game = game
	driver.fail_mode = OS.get_environment("WALKER_CAPTURE_MODE") == "fail"
	driver.log_path = OS.get_environment("WALKER_CAPTURE_LOG")
	var sx := OS.get_environment("WALKER_CAPTURE_STOP_X")
	if sx != "":
		driver.stop_x = float(sx)
	var ws := OS.get_environment("WALKER_CAPTURE_WATCH")
	if ws != "":
		driver.watch_s = float(ws)
	add_child(driver)

func _physics_process(_delta: float) -> void:
	frames += 1
	if game == null or not is_instance_valid(game):
		return
	# Hold a beat on the completion screen, then stop cleanly so the movie
	# header finalizes. Never force COMPLETE — only react to it.
	if game.state == Game.State.COMPLETE and tail < 0:
		tail = 90
	if tail > 0:
		tail -= 1
	if tail == 0 or frames >= max_frames:
		driver._flush_log()
		print("CAPTURE END frames=%d state=%d deaths=%d x=%.2f" % [
			frames, game.state, game.deaths, game.player.position.x])
		get_tree().quit(0)
