class_name PlayerFallState
extends PlayerState

var air_time: float = 0.0
var coyote_connected: bool = false
var grace_jump: bool = false

func _ready() -> void:
	state_name = "fall"

## Args[0] should be the name of the previous state.
func enter(args: Array) -> void:
	super(args)

	# Setup Coyote Time if this is a natural fall.
	if args[0] != "jump":
		parent.coyote_timer.timeout.connect(_on_coyote_timer_timeout)
		parent.coyote_timer.start()
		coyote_connected = true
		grace_jump = true
	else:
		grace_jump = false

func exit(new_state: StringName) -> void:
	super(new_state)
	air_time = 0.0
	
	# Teardown the coyote timer.
	if coyote_connected:
		parent.coyote_timer.stop()
		parent.coyote_timer.timeout.disconnect(_on_coyote_timer_timeout)
		coyote_connected = false
	grace_jump = false

## Fall state overrides the default state change logic due to coyote time interactions with jumping.
func physics_update(delta) -> void:
	super(delta)
	parent.increase_light()
	
	var attempted_jump: bool = Input.is_action_just_pressed("player_jump")
	if attempted_jump && grace_jump:
		grace_jump = false
		parent.coyote_timer.stop()
		transition.emit("jump", [state_name])
		return
	elif attempted_jump && !grace_jump:
		# Buffer the jump and start the timer.
		parent.input_buffer_timer.start()
		parent.buffered_input = "jump"
	
	if !parent.is_hurt:
		var direction: float = Input.get_axis("player_left", "player_right")
		if direction:
			parent.direction_component.set_direction_from_int(direction)
			parent.velocity.x = direction * parent.speed
		else:
			parent.velocity.x = move_toward(parent.velocity.x, 0, parent.speed)

func _on_coyote_timer_timeout() -> void:
	grace_jump = false
