extends RefCounted
## Fixed input route through the real level. No position/velocity edits.
##
## Each mark is a launch point in world x. Options:
##   "wait"  stand still at the mark until the cycling platform has enough solid
##           phase left to land on and jump off again, then commit.
##   "hold"  ticks to keep holding right after launching, then release. Shortens
##           the arc for the two landings that need it: the 40 px spike slot and
##           the strip past the second cluster. Without it every jump is the same
##           ~109 px and both landings fall on spikes.
var marks: Array[Dictionary] = [
	{"x": 138.0}, {"x": 292.0}, {"x": 424.0}, {"x": 548.0}, {"x": 712.0},
	{"x": 840.0},                        # Ground C -> bounce pad (pad launches on contact)
	{"x": 1078.0, "wait": true},         # observation deck -> cycling platform
	{"x": 1172.0},                       # cycling platform -> spike strip, ahead of cluster 1
	{"x": 1285.0, "hold": 22},           # short hop into the slot between the clusters
	{"x": 1350.0, "hold": 24},           # short hop over cluster 2 onto the finish
]
var next_jump: int = 0
var game = null                          # session, for the cycle query; optional
var needed_solid: float = 0.9            # seconds of solid phase required before committing
var hold_left: int = -1

func step(player: CharacterBody2D) -> void:
	player.test_control = true
	player.test_jump_held = false
	var axis := 1.0
	if hold_left > 0:
		hold_left -= 1
	elif hold_left == 0:
		axis = 0.0
		if player.is_on_floor():
			hold_left = -1
	if next_jump < marks.size():
		var m: Dictionary = marks[next_jump]
		if player.position.x >= float(m.x):
			if bool(m.get("wait", false)) and not _ready_to_commit(player):
				axis = 0.0
			elif player.is_on_floor():
				player.test_jump_pressed = true
				hold_left = int(m.get("hold", -1))
				next_jump += 1
				axis = 1.0
	player.test_axis = axis

func _ready_to_commit(player: CharacterBody2D) -> bool:
	# Launch from a standstill so the arc is repeatable, and only when the platform
	# will still be solid on arrival.
	if not player.is_on_floor() or absf(player.velocity.x) > 1.0:
		return false
	if game == null:
		return true
	return game.cycle_solid_left(0) >= needed_solid
