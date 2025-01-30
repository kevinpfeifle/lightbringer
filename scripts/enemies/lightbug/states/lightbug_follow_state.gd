class_name LightbugFollowState
extends State

@export var abandon_follow_timer: Timer

# TODO: Reusing the Orbi chase logic for the sake of time. Post-jam refactor this whole section and make it 
# a "FollowComponent" or something similar since it is clearly re-usable logic. The knockback component would need
# to stay in OrbiChaseState, but the rest likely could get added into some sort of component that tells you
# what your velocity should be.

var following: bool
var follow_target: CharacterBody2D
var target_position: Vector2
var returning_home: bool = false

func _ready() -> void:
	state_name = "follow"

# args[1] is a reference to the body being chased, the Player.
func enter(args: Array) -> void:
	super(args)
	abandon_follow_timer.timeout.connect(_on_follow_abandoned)
	following = true
	follow_target = args[1]
	target_position = _update_target_position()

func exit(new_state: StringName) -> void:
	super(new_state)
	following = false
	abandon_follow_timer.timeout.disconnect(_on_follow_abandoned)

func physics_update(delta) -> void:
	super(delta)

	# As soon as a lantern is seen by the Lightbug, its "home" changes to the lantern, so exit follow logic.
	if parent.lantern_home:
		transition.emit("wander", [state_name])
		return

	# Start the timer to abandon the chase if the player leaves the range.
	if !parent.player_detected && following && abandon_follow_timer.is_stopped():
		abandon_follow_timer.start()
		following = false
		parent.velocity = Vector2.ZERO
	elif !follow_target.alive && !returning_home:
		following = false
		returning_home = true
		_update_target_position()
	elif follow_target.alive && parent.player_detected:
		# If the player is detected while it was waiting to abandon, stop the timer, continue chase.
		if !abandon_follow_timer.is_stopped():
			abandon_follow_timer.stop()
			following = true
		# If the Orbi was returning home, the player has to enter its detection range again to agro, not just its chase range.
		elif returning_home && parent.player_noticed:
			following = true
			returning_home = false
		_update_target_position()

	if (following || returning_home) && !parent.nav_agent.is_navigation_finished():
		var speed = parent.speed
		var current_location = parent.global_position
		var next_location = parent.nav_agent.get_next_path_position()
		parent.velocity = parent.velocity.lerp((next_location - current_location).normalized() * speed, 0.1)
		parent.direction_component.set_direction_from_int(parent.velocity.x)
	elif parent.global_position.distance_to(parent.home) < 10:
		transition.emit("wander", [state_name])

func _on_follow_abandoned() -> void:
	returning_home = true
	_update_target_position()

func _update_target_position() -> Vector2:
	if returning_home:
		target_position = parent.home
	else:
		var new_target_position: Vector2 = follow_target.global_position
		if new_target_position != target_position:
			target_position = new_target_position
	parent.nav_agent.target_position = target_position
	return target_position