extends Node2D

const Player = preload("res://features/player/player.gd")
const Hud = preload("res://ui/hud.gd")
enum State { MENU, PLAYING, PAUSED, DYING, COMPLETE }
var state: State = State.MENU
var player: CharacterBody2D
var camera: Camera2D
var hud: Control
var level: Dictionary
var hazard_areas: Array[Area2D] = []
var cycling_bodies: Array[StaticBody2D] = []
var goal: Area2D
var deaths: int = 0
var elapsed: float = 0.0
var retry_remaining: float = 0.0
var death_reason: String = ""
var last_finish_time: float = 0.0
var test_mode: bool = false
var contact_settle_ticks: int = 0

func _ready() -> void:
	process_physics_priority = 10
	level = JSON.parse_string(FileAccess.get_file_as_string("res://levels/first_steps.json"))
	_setup_input()
	for entry in level.solids:
		_add_solid(Rect2(entry[0], entry[1], entry[2], entry[3]))
	# Pads are ordinary solids that also launch; they stand apart in the data, not by coordinate.
	for entry in level.get("pads", []):
		_add_solid(Rect2(entry[0], entry[1], entry[2], entry[3]))
	for entry in level.get("cycling", []):
		var c: Array = entry.rect
		cycling_bodies.append(_add_solid(Rect2(c[0], c[1], c[2], c[3])))
	_add_solid(Rect2(-32, 0, 32, 430))
	_add_solid(Rect2(level.width, 0, 32, 430))
	for entry in level.hazards:
		hazard_areas.append(_add_area(Rect2(entry[0], entry[1], entry[2], entry[3]), 8, true))
	var f: Array = level.finish
	goal = _add_area(Rect2(f[0], f[1], f[2], f[3]), 16, false)
	player = Player.new()
	add_child(player)
	player.reset_at(Vector2(level.spawn[0], level.spawn[1]))
	camera = Camera2D.new()
	camera.position = Vector2(320, 180)
	add_child(camera)
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Hud.new()
	hud.game = self
	layer.add_child(hud)
	get_window().focus_exited.connect(_on_focus_lost)
	queue_redraw()

func _setup_input() -> void:
	var actions := {"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT], "jump": [KEY_SPACE], "pause": [KEY_ESCAPE, KEY_P], "restart": [KEY_R], "confirm": [KEY_ENTER], "menu": [KEY_M]}
	for action in actions:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		for key in actions[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)

func _add_solid(rect: Rect2) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = rect.position + rect.size / 2
	body.collision_layer = 1
	body.collision_mask = 2
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	body.add_child(collision)
	add_child(body)
	return body

func _add_area(rect: Rect2, layer: int, spikes: bool) -> Area2D:
	var area := Area2D.new()
	area.position = rect.position
	area.collision_layer = layer
	area.collision_mask = 2
	if spikes:
		# Three exact triangular trigger silhouettes; no oversized invisible box.
		for i in range(3):
			var triangle := CollisionPolygon2D.new()
			var x := float(i) * rect.size.x / 3.0
			triangle.polygon = PackedVector2Array([Vector2(x, rect.size.y), Vector2(x + 4, 0), Vector2(x + 8, rect.size.y)])
			area.add_child(triangle)
	else:
		var collision := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		collision.shape = shape
		collision.position = rect.size / 2.0
		area.add_child(collision)
	add_child(area)
	return area

func start_session() -> void:
	if state == State.PLAYING:
		return
	deaths = 0
	restart_attempt()

func restart_attempt() -> void:
	state = State.PLAYING
	elapsed = 0.0
	retry_remaining = 0.0
	# Area2D overlaps are physics-step snapshots. Discard pre-teleport contacts
	# until the broadphase has observed the reset, preventing a phantom second death.
	contact_settle_ticks = 2
	player.reset_at(Vector2(level.spawn[0], level.spawn[1]))
	player.enabled = true
	camera.position = Vector2(320, 180)
	_update_cycling()

func set_paused(value: bool) -> void:
	if value and state == State.PLAYING:
		state = State.PAUSED
		player.enabled = false
	elif not value and state == State.PAUSED:
		state = State.PLAYING
		player.enabled = true
		player.require_jump_release = true
		player.jump_request_tick = -1000

func _on_focus_lost() -> void:
	if not test_mode:
		set_paused(true)

func resolve_contacts(fatal: bool, finished: bool) -> void:
	if state != State.PLAYING:
		return
	if fatal:
		state = State.DYING
		deaths += 1
		retry_remaining = 0.55
		player.enabled = false
		player.velocity = Vector2.ZERO
	elif finished:
		state = State.COMPLETE
		last_finish_time = elapsed
		player.enabled = false
		player.velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if state == State.DYING:
		retry_remaining -= delta
		if retry_remaining <= 0:
			restart_attempt()
	elif state == State.PLAYING:
		elapsed += delta
		_update_cycling()
		# The rest of the level is static and drawn once in _ready(); a cycling platform is the
		# only thing here that changes, so it is the only reason to redraw.
		if not cycling_bodies.is_empty():
			queue_redraw()
		var fatal := player.position.y > float(level.fall_y)
		death_reason = "Missed the landing" if fatal else "Watch the spikes"
		for hazard in hazard_areas:
			fatal = fatal or hazard.overlaps_body(player)
		if contact_settle_ticks > 0:
			contact_settle_ticks -= 1
		else:
			resolve_contacts(fatal, goal.overlaps_body(player))
		if state == State.PLAYING:
			_apply_pads()
		camera.position.x = clampf(player.position.x + 100, 320, float(level.width) - 320)
	if is_instance_valid(hud):
		hud.queue_redraw()

func _cycle_phase(entry: Dictionary) -> Dictionary:
	# Derived from `elapsed`, never stored: it only advances while PLAYING, resets to 0 on
	# every attempt, and is driven by the fixed physics delta — so the cycle is reproducible.
	var cycle: float = maxf(0.001, float(entry.cycle))
	var on: float = cycle * float(entry.on_ratio)
	var t: float = fmod(elapsed + float(entry.phase), cycle)
	return {"solid": t < on, "warn": t >= on - 0.5 and t < on, "left": maxf(0.0, on - t)}

func cycle_solid_left(index: int) -> float:
	## Seconds of solid phase remaining, 0.0 while absent. For fixtures that must commit
	## to a jump only when the platform will still be there on arrival.
	var entries: Array = level.get("cycling", [])
	if index < 0 or index >= entries.size():
		return 0.0
	var p := _cycle_phase(entries[index])
	return p.left if p.solid else 0.0

func _update_cycling() -> void:
	var entries: Array = level.get("cycling", [])
	for i in mini(entries.size(), cycling_bodies.size()):
		var shape := cycling_bodies[i].get_child(0) as CollisionShape2D
		var solid: bool = _cycle_phase(entries[i]).solid
		# Deferred so the shape never toggles inside a running physics query.
		if shape.disabled == solid:
			shape.set_deferred("disabled", not solid)

func _apply_pads() -> void:
	# Runs after the player's own step, so this replaces whatever velocity the landing left.
	# Consuming the jump opportunity stops a same-tick jump from cutting the launch to -320.
	if not player.is_on_floor():
		return
	for entry in level.get("pads", []):
		var r := Rect2(entry[0], entry[1], entry[2], entry[3])
		if absf(player.position.y - r.position.y) > 2.0:
			continue
		if player.position.x < r.position.x - 9.0 or player.position.x > r.end.x + 9.0:
			continue
		player.velocity.y = player.tuning.BOUNCE_VELOCITY
		player.opportunity_consumed = true
		player.jump_request_tick = -1000
		return

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		return
	if event.is_action_pressed("confirm"):
		if state in [State.MENU, State.COMPLETE]:
			start_session()
		elif state == State.PAUSED:
			set_paused(false)
	elif event.is_action_pressed("pause"):
		set_paused(state != State.PAUSED)
	elif event.is_action_pressed("restart") and state in [State.PLAYING, State.PAUSED, State.DYING]:
		restart_attempt()
	elif event.is_action_pressed("menu") and state in [State.PAUSED, State.COMPLETE]:
		state = State.MENU
		player.enabled = false
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Rect2(220, 215, 200, 34).has_point(hud.get_local_mouse_position()):
			if state in [State.MENU, State.COMPLETE]:
				start_session()
			elif state == State.PAUSED:
				set_paused(false)

func _draw_platform(r: Rect2, ink: Color, alpha: float) -> void:
	draw_rect(r, Color(ink, alpha))
	draw_rect(Rect2(r.position, Vector2(r.size.x, 4)), Color(Color("438e7d"), alpha))
	# 45-degree hatch starting 12px down; shortened so it stays inside thin platforms.
	var hatch: float = minf(7.0, r.size.y - 12.0)
	if hatch > 0.0:
		for x in range(int(r.position.x)+12, int(r.end.x), 24):
			draw_line(Vector2(x, r.position.y+12), Vector2(x+hatch, r.position.y+12+hatch), Color(Color("405166"), alpha), 1)

func _draw() -> void:
	if level.is_empty():
		return
	var font := ThemeDB.fallback_font
	var ink := Color("25354a")
	var width: float = level.width
	# All visual assets are original Godot vector drawing, not recovered art.
	draw_rect(Rect2(-400, -200, width + 800, 900), Color("f6f3ec"))
	for x in range(0, int(width) + 1, 32):
		draw_line(Vector2(x, 80), Vector2(x, 320), Color("e7e5df"), 1)
	for y in range(96, 321, 32):
		draw_line(Vector2(0, y), Vector2(width, y), Color("e7e5df"), 1)
	for x in [100, 470, 770, 1070, 1370]:
		draw_colored_polygon(PackedVector2Array([Vector2(x-90,320),Vector2(x+50,180),Vector2(x+190,320)]), Color("e4e8e3"))
	for entry in level.solids:
		_draw_platform(Rect2(entry[0], entry[1], entry[2], entry[3]), ink, 1.0)
	for entry in level.get("cycling", []):
		var c: Array = entry.rect
		var r := Rect2(c[0], c[1], c[2], c[3])
		var phase := _cycle_phase(entry)
		if not phase.solid:
			# Ghost outline so the landing spot stays legible while it is gone.
			draw_rect(r, Color(ink, 0.16), false, 1.0)
		elif phase.warn and fmod(elapsed * 8.0, 1.0) < 0.5:
			# Last half second: blink down rather than out, so it never reads as already gone.
			_draw_platform(r, ink, 0.35)
		else:
			_draw_platform(r, ink, 1.0)
	for entry in level.get("pads", []):
		var p := Rect2(entry[0], entry[1], entry[2], entry[3])
		draw_rect(p, ink)
		draw_rect(Rect2(p.position, Vector2(p.size.x, 4)), Color("ef875f"))
		# Upward chevrons instead of hatching, so it reads as a launcher rather than a ledge.
		for i in range(3):
			var cx: float = p.position.x + p.size.x * (i + 0.5) / 3.0
			var cy: float = p.position.y + 11.0
			draw_line(Vector2(cx-4, cy), Vector2(cx, cy-5), Color("ef875f"), 2)
			draw_line(Vector2(cx, cy-5), Vector2(cx+4, cy), Color("ef875f"), 2)
	for entry in level.hazards:
		var h := Rect2(entry[0], entry[1], entry[2], entry[3])
		for i in range(maxi(1, int(h.size.x / 8.0))):
			var x: float = h.position.x + i*8.0
			draw_colored_polygon(PackedVector2Array([Vector2(x,h.end.y),Vector2(x+4,h.position.y),Vector2(x+8,h.end.y)]), Color("d24e42"))
	var f := Rect2(level.finish[0], level.finish[1], level.finish[2], level.finish[3])
	var pole_top: float = f.position.y - 14.0
	draw_line(Vector2(f.position.x+3, f.end.y), Vector2(f.position.x+3, pole_top), ink, 3)
	draw_colored_polygon(PackedVector2Array([Vector2(f.position.x+5,pole_top),Vector2(f.position.x+32,pole_top+10),Vector2(f.position.x+5,pole_top+24)]), Color("287c68"))
	draw_string(font, Vector2(33, 251), "01 / GET MOVING", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, ink)
	draw_string(font, Vector2(33, 273), "Read the landing. Then jump.", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, ink)
	draw_string(font, Vector2(474, 227), "02 / MIND THE GAP", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, ink)
	draw_string(font, Vector2(1008, 155), "03 / MIND THE CLOCK", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, ink)
	draw_string(font, Vector2(1008, 177), "Watch it blink. Then go.", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, ink)
	draw_string(font, Vector2(1240, 155), "04 / THREAD THE NEEDLE", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, ink)
	draw_string(font, Vector2(1240, 177), "Land between them.", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, ink)
	draw_string(font, Vector2(f.position.x-38, f.position.y-39), "FINISH", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, ink)
