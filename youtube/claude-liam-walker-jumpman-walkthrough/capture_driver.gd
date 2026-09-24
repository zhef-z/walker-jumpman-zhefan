extends Node
## Input-only capture route for the walkthrough film.
##
## Unlike tests/route_driver.gd — which writes player.test_axis / test_jump_pressed
## and so bypasses Input entirely — this driver presses and releases the REAL
## actions through Input.action_press / Input.action_release. It reads
## player.position, player.is_on_floor(), game.state and game.cycle_solid_left()
## to decide WHEN to press, and writes nothing back: no position, no velocity,
## no game state, no test-only shortcut.
##
## Runs at physics priority -20, ahead of the player (0) and the session (10),
## so a press is visible to the player on the same tick it is issued.
##
## fail_mode = true commits to the cycling platform while it is ABSENT, so the
## take contains a genuine death and the retry that follows. The attempt after
## the death runs the normal route, so one take shows failure, recovery and
## completion.

const Game = preload("res://game/session.gd")

var game: Node2D
var fail_mode: bool = false
var log_path: String = ""
## Observation mode: walk the normal route only as far as stop_x, then stand
## still. Used for the prediction-3 reconstruction, where the camera needs to
## rest at the right end of Ground C. Standing still is an input choice, not a
## teleport or a frozen frame.
var stop_x: float = 0.0
## Observation mode for the cycling platform: once standing at the wait mark,
## deliberately let this many seconds pass before applying the normal commit
## rule, so the take shows the platform blink, vanish and come back. This only
## delays a decision the driver was already free to make; it changes nothing
## about the game.
var watch_s: float = 0.0
var watch_started: int = -1

## Same launch points as tests/route_driver.gd. "wait" holds position until the
## cycling platform has enough solid phase left; "hold" releases right after N
## ticks to shorten the arc for the two precision landings.
var marks: Array[Dictionary] = [
	{"x": 138.0}, {"x": 292.0}, {"x": 424.0}, {"x": 548.0}, {"x": 712.0},
	{"x": 840.0},
	{"x": 1070.0, "wait": true},
	{"x": 1172.0},
	{"x": 1285.0, "hold": 22},
	{"x": 1350.0, "hold": 24},
]
var needed_solid: float = 0.9

var tick: int = 0
var next_jump: int = 0
var hold_left: int = -1
var jump_down: bool = false
var started: bool = false
var attempt: int = 0
var deliberate_miss_used: bool = false
var last_state: int = -1
var events: Array = []

func _ready() -> void:
	process_physics_priority = -20

func _exit_tree() -> void:
	_flush_log()

func _flush_log() -> void:
	if log_path == "":
		return
	var f := FileAccess.open(log_path, FileAccess.WRITE)
	if f == null:
		return
	for e in events:
		f.store_line(JSON.stringify(e))
	f.close()

func _note(action: String, edge: String, extra: Dictionary = {}) -> void:
	var row := {
		"tick": tick, "action": action, "edge": edge, "attempt": attempt,
		"state": game.state if game != null else -1,
	}
	if game != null and game.player != null:
		row["x"] = snappedf(game.player.position.x, 0.001)
		row["y"] = snappedf(game.player.position.y, 0.001)
	for k in extra:
		row[k] = extra[k]
	events.append(row)

var down: Dictionary = {}

func _send(action: String, pressed: bool) -> void:
	# A real InputEvent, not just a polled action state: session.gd starts and
	# pauses from _unhandled_input, which only sees events, while player.gd polls
	# Input.get_axis / is_action_just_pressed. parse_input_event drives both.
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = pressed
	ev.strength = 1.0 if pressed else 0.0
	Input.parse_input_event(ev)
	down[action] = pressed

func _press(action: String) -> void:
	if not down.get(action, false):
		_send(action, true)
		_note(action, "press")

func _release(action: String) -> void:
	if down.get(action, false):
		_send(action, false)
		_note(action, "release")

func _release_all() -> void:
	_release("move_right")
	_release("move_left")
	_release("jump")
	jump_down = false

func _reset_route() -> void:
	next_jump = 0
	hold_left = -1
	_release_all()

func _physics_process(_delta: float) -> void:
	if game == null or not is_instance_valid(game) or game.player == null:
		return
	tick += 1

	# A jump is a one-tick tap; let go before anything else this tick.
	if jump_down:
		_release("jump")
		jump_down = false

	if game.state != last_state:
		if last_state == Game.State.DYING and game.state == Game.State.PLAYING:
			attempt += 1
			_note("respawn", "state", {"deaths": game.deaths})
			_reset_route()
		last_state = game.state

	# Start from the menu through the normal confirm action, not start_session().
	if game.state == Game.State.MENU:
		if not started:
			started = true
			_press("confirm")
			jump_down = false
		else:
			_release("confirm")
		return
	_release("confirm")

	if game.state != Game.State.PLAYING:
		_release_all()
		return

	var player = game.player
	var want_right := true

	if stop_x > 0.0 and player.position.x >= stop_x:
		_release_all()
		return

	if hold_left > 0:
		hold_left -= 1
	elif hold_left == 0:
		want_right = false
		if player.is_on_floor():
			hold_left = -1

	if next_jump < marks.size():
		var m: Dictionary = marks[next_jump]
		if player.position.x >= float(m.x):
			if bool(m.get("wait", false)) and not _commit(player):
				want_right = false
			elif player.is_on_floor():
				_send("jump", true)
				jump_down = true
				_note("jump", "press", {"mark": next_jump, "mark_x": m.x})
				hold_left = int(m.get("hold", -1))
				next_jump += 1
				want_right = true

	if want_right:
		_press("move_right")
	else:
		_release("move_right")

func _commit(player) -> bool:
	if not player.is_on_floor() or absf(player.velocity.x) > 1.0:
		return false
	if watch_s > 0.0:
		if watch_started < 0:
			watch_started = tick
			_note("watch_start", "decision", {"seconds": watch_s})
		if float(tick - watch_started) / 60.0 < watch_s:
			return false
	var left: float = game.cycle_solid_left(0)
	if fail_mode and not deliberate_miss_used:
		# Deliberately step off while the platform is gone. This is a real jump
		# into a real gap; nothing is disabled to make it fail.
		if left <= 0.0:
			deliberate_miss_used = true
			_note("deliberate_miss", "decision", {"cycle_solid_left": 0.0})
			return true
		return false
	return left >= needed_solid
