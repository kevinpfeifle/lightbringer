class_name OrbiChaseState
extends State

@export var abandon_chase_timer: Timer

var chasing: bool
# var nav_ready: bool = false
var chase_target: CharacterBody2D
var target_position: Vector2
var returning_home: bool = false

func _ready() -> void:
	state_name = "chase"

# args[1] is a reference to the body being chased, the Player.
func enter(args: Array) -> void:
	super(args)
	abandon_chase_timer.timeout.connect(_on_chase_abandoned)
	chasing = true
	chase_target = args[1]
	target_position = _update_target_position()

func exit(new_state: StringName) -> void:
	super(new_state)
	chasing = false
	abandon_chase_timer.timeout.disconnect(_on_chase_abandoned)

func physics_update(delta) -> void:
	super(delta)

	# Start the timer to abandon the chase if the player leaves the range.
	if !parent.player_detected && chasing && abandon_chase_timer.is_stopped():
		abandon_chase_timer.start()
		chasing = false
		parent.velocity = Vector2.ZERO
	elif !chase_target.alive && !returning_home:
		chasing = false
		returning_home = true
		_update_target_position()
	elif chase_target.alive && parent.player_detected:
		# If the player is detected while it was waiting to abandon, stop the timer, continue chase.
		if !abandon_chase_timer.is_stopped():
			abandon_chase_timer.stop()
			chasing = true
		# If the Orbi was returning home, the player has to enter its detection range again to agro, not just its chase range.
		elif returning_home && parent.player_noticed:
			chasing = true
			returning_home = false
		_update_target_position()

	if (chasing || returning_home) && !parent.nav_agent.is_navigation_finished():
		var speed = parent.speed
		if parent.player_noticed:
			speed = parent.chase_speed
		var current_location = parent.global_position
		var next_location = parent.nav_agent.get_next_path_position()
		parent.velocity = parent.velocity.lerp((next_location - current_location).normalized() * speed, 0.1)
		parent.knockback_component.handle_knockback(parent)
	elif parent.global_position.distance_to(parent.home) < 10:
		transition.emit("wander", [state_name])

func _on_chase_abandoned() -> void:
	returning_home = true
	_update_target_position()

func _update_target_position() -> Vector2:
	if returning_home:
		target_position = parent.home
	else:
		var new_target_position: Vector2 = chase_target.global_position
		if new_target_position != target_position:
			target_position = new_target_position
	parent.nav_agent.target_position = target_position
	return target_position