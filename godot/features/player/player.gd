extends CharacterBody2D

const Tuning = preload("res://features/player/tuning.gd")

const BONE := Color("E0C48F")
const BONE_EDGE := Color("8A7550")
const COLLAR := Color("2A2A2A")
const COLLAR_LINE := Color("555555")
const GEM := Color("4FBCCB")
const GEM_CORE := Color("A8E8EC")
const GEM_AIR := Color("7FE0EE")
const GEM_CORE_AIR := Color("E8FBFB")
const BALL := Color("5BC8D8")
const BALL_AIR := Color("8FE8F2")
const CAPE := Color("4BA3D8")
const CAPE_EDGE := Color("2A7BAE")
const BELLY := Color("BFEFEF")
const BELLY_CORE := Color("8FDCDC")
const BELLY_AIR := Color("DFFAFA")
const BELLY_CORE_AIR := Color("A8EFEF")

var HEAD := PackedVector2Array([
	Vector2(-5, -16), Vector2(-8.5, -25), Vector2(-8.5, -28), Vector2(-5.8, -28),
	Vector2(-5.8, -25), Vector2(-1.4, -25), Vector2(-1.4, -28), Vector2(1.4, -28),
	Vector2(1.4, -25), Vector2(5.8, -25), Vector2(5.8, -28), Vector2(8.5, -28),
	Vector2(8.5, -25), Vector2(5, -16)])

var tuning = Tuning.new()
var enabled: bool = false
var tick: int = 0
var last_floor_tick: int = -1000
var jump_request_tick: int = -1000
var opportunity_consumed: bool = false
var require_jump_release: bool = true
var facing: float = 1.0
var jumps: int = 0
var test_control: bool = false
var test_axis: float = 0.0
var test_jump_pressed: bool = false
var test_jump_held: bool = false

func _ready() -> void:
	name = "Player"
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 1.0
	var shape := RectangleShape2D.new()
	shape.size = Vector2(18, 28)
	var collider := CollisionShape2D.new()
	collider.shape = shape
	collider.position = Vector2(0, -14)
	add_child(collider)

func reset_at(spawn: Vector2) -> void:
	position = spawn
	velocity = Vector2.ZERO
	last_floor_tick = -1000
	jump_request_tick = -1000
	opportunity_consumed = false
	require_jump_release = true
	test_jump_pressed = false
	jumps = 0
	queue_redraw()

func _physics_process(delta: float) -> void:
	if not enabled:
		return
	tick += 1
	var axis := test_axis if test_control else Input.get_axis("move_left", "move_right")
	var held := test_jump_held if test_control else Input.is_action_pressed("jump")
	var pressed := test_jump_pressed if test_control else Input.is_action_just_pressed("jump")
	test_jump_pressed = false
	if not held:
		require_jump_release = false
	if is_on_floor() and velocity.y >= 0.0:
		last_floor_tick = tick
		opportunity_consumed = false
	if pressed and not require_jump_release:
		jump_request_tick = tick
	var rate: float = tuning.acceleration if not is_zero_approx(axis) else tuning.deceleration
	velocity.x = move_toward(velocity.x, axis * tuning.speed, rate * delta)
	if not is_zero_approx(axis):
		facing = signf(axis)
	velocity.y = minf(velocity.y + tuning.gravity * delta, tuning.terminal_velocity)
	if not opportunity_consumed and tick - last_floor_tick <= tuning.coyote_ticks and tick - jump_request_tick <= tuning.buffer_ticks:
		velocity.y = tuning.jump_velocity
		opportunity_consumed = true
		jump_request_tick = -1000
		jumps += 1
	move_and_slide()
	position.x = maxf(position.x, 10.0)
	queue_redraw()

func _draw() -> void:
	var px := 1.0 if facing > 0 else -1.0
	var air := not is_on_floor()
	var stride := sin(float(tick) * 0.7) * 2.0 if not air and absf(velocity.x) > 8 else 0.0
	var lift_l := maxf(stride, 0.0)
	var lift_r := maxf(-stride, 0.0)
	# Concave: three prongs notched over a tapered skull. Outline is a separate polyline.
	draw_colored_polygon(HEAD, BONE)
	var head_outline := HEAD.duplicate()
	head_outline.append(HEAD[0])
	draw_polyline(head_outline, BONE_EDGE, 1.0)
	draw_circle(Vector2(0.5 * px, -23.4), 1.25 if air else 0.95, BALL_AIR if air else BALL)
	# Gem stays swung to the head edge in both states; airborne only changes size and colour.
	var gem := Vector2(2.2 * px, -19.7)
	draw_circle(gem, 2.6 if air else 2.3, GEM_AIR if air else GEM)
	draw_circle(gem, 0.9 if air else 1.25, GEM_CORE_AIR if air else GEM_CORE)
	draw_rect(Rect2(-3.6, -16, 7.2, 1.8), COLLAR)
	draw_rect(Rect2(-3.6, -15.6, 7.2, 0.3), COLLAR_LINE)
	draw_rect(Rect2(-3.6, -14.9, 7.2, 0.3), COLLAR_LINE)
	var arm_y := -15.3 if air else -14.2
	for arm_x in [-9.0, 6.3]:
		draw_rect(Rect2(arm_x, arm_y, 2.7, 7.7), BONE)
		draw_rect(Rect2(arm_x, arm_y + 7.7, 0.9, 1.7), BONE_EDGE)
		draw_rect(Rect2(arm_x + 1.8, arm_y + 7.7, 0.9, 1.7), BONE_EDGE)
	var cape_dy := -0.55 if air else 0.0
	var cape := PackedVector2Array([Vector2(-7, -14.4 + cape_dy), Vector2(7, -14.4 + cape_dy), Vector2(7, -8.5 + cape_dy), Vector2(0, -4.4 + cape_dy), Vector2(-7, -8.5 + cape_dy)])
	draw_colored_polygon(cape, CAPE)
	var cape_outline := cape.duplicate()
	cape_outline.append(cape[0])
	draw_polyline(cape_outline, CAPE_EDGE, 1.0)
	draw_circle(Vector2(0, -9.6), 2.95 if air else 2.65, BELLY_AIR if air else BELLY)
	draw_circle(Vector2(0, -9.6), 1.3 if air else 1.1, BELLY_CORE_AIR if air else BELLY_CORE)
	# Legs shorten upward on the walk cycle; never cross y = 0.
	draw_rect(Rect2(-5.8, -4.4, 4.7, 4.4 - lift_l), BONE)
	draw_rect(Rect2(1.1, -4.4, 4.7, 4.4 - lift_r), BONE)
	if air:
		var flame := 7.0 if velocity.y < 0 else 4.0
		for cx in [-3.5, 3.5]:
			draw_colored_polygon(PackedVector2Array([Vector2(cx - 2.2, 0), Vector2(cx + 2.2, 0), Vector2(cx, flame)]), CAPE)
			draw_colored_polygon(PackedVector2Array([Vector2(cx - 1.1, 0), Vector2(cx + 1.1, 0), Vector2(cx, flame * 0.6)]), GEM_CORE)
