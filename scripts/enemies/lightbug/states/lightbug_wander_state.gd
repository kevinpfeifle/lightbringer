class_name LightbugWanderState
extends State

@export var wander_leash_distance: int

# TODO: Reusing the Orbi wander logic for the sake of time. Post-jam refactor this whole section and make it 
# a "WanderComponent" or something similar since it is clearly re-usable logic. The knockback component would need
# to stay in OrbiWanderState, but the rest likely could get added into some sort of component that tells you
# what your velocity should be.

const WANDER_MIN_TIMER: int = 1
const WANDER_MAX_TIMER: int = 5

var nav_ready: bool = false
var wander_target: Vector2

func _ready() -> void:
	state_name = "wander"

func enter(args: Array) -> void:
	super(args)
	NavigationServer2D.map_changed.connect(_on_map_ready)
	parent.wait_timer.timeout.connect(_on_wait_timer_timeout)
	parent.wander_timer.timeout.connect(_on_wander_timer_timeout)
	if nav_ready:
		parent.wander_timer.start()

func exit(new_state: StringName) -> void:
	super(new_state)
	NavigationServer2D.map_changed.disconnect(_on_map_ready)
	parent.wait_timer.timeout.disconnect(_on_wait_timer_timeout)
	parent.wander_timer.timeout.disconnect(_on_wander_timer_timeout)

func physics_update(delta) -> void:
	super(delta)

	if nav_ready:
		if parent.global_position.distance_to(wander_target) > 5 && !parent.nav_agent.is_target_reached():
			if parent.wander_timer.is_stopped():
				parent.wander_timer.start()
			var current_location = parent.global_position
			var next_location = parent.nav_agent.get_next_path_position()
			if parent.nav_agent.is_target_reachable():
				parent.velocity = (next_location - current_location).normalized() * parent.speed
			else:
				parent.velocity = Vector2(0, 0)
				if parent.wait_timer.is_stopped():
					parent.wait_timer.start()
					parent.wander_timer.stop()
		else:
			parent.velocity = Vector2(0, 0)
			if parent.wait_timer.is_stopped():
				parent.wait_timer.start()
				parent.wander_timer.stop()

	parent.direction_component.set_direction_from_int(parent.velocity.x)

func _new_wander_target() -> Vector2:
	# If the Orbi hasn't wandered too far, keep wandering.
	if parent.global_position.distance_to(parent.home) <= wander_leash_distance:
		var shape = parent.wander_area.get_child(0).shape as CircleShape2D
		var radius = shape.radius
		var angle = randf() * TAU # Generate a random point within the circle
		var random_distance_weight = randf()
		var distance = lerp(radius * 0.33, radius, random_distance_weight)  # Favor larger distance
		var local_point = Vector2(cos(angle), sin(angle)) * distance
		wander_target = parent.wander_area.to_global(local_point)
	else:
		# Otherwise wander back towards the Orbi's home location this cycle.
		wander_target = parent.home
	parent.nav_agent.target_position = wander_target
	return wander_target

func _on_map_ready(_map: RID) -> void:
	wander_target = _new_wander_target()
	nav_ready = true

func _on_wander_timer_timeout() -> void:
	# If after 5 seconds pick a new direction to wander. Prevents the Orbi from getting stuck trying to go somewhere it cant.
	wander_target = _new_wander_target()

func _on_wait_timer_timeout() -> void:
	wander_target = _new_wander_target()
	parent.wait_timer.wait_time = lerp(WANDER_MIN_TIMER, WANDER_MAX_TIMER, randf()) # Change the timer each time to be between 1 - 5 seconds.
