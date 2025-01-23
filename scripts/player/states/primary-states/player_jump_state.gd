class_name PlayerJumpState
extends PlayerState

func _ready() -> void:
	state_name = "jump"

func enter(args: Array) -> void:
	super(args)
	if Input.is_action_just_released("player_jump"):
		parent.velocity.y = parent.JUMP_CLIP_VELOCITY
	else:
		parent.velocity.y = parent.JUMP_VELOCITY

func physics_update(delta) -> void: 
	super(delta)

	# Buffer the next jump if a player is attempting a new jump mid-jump. This might happen when platforming.
	var attempted_jump: bool = Input.is_action_just_pressed("player_jump")
	if attempted_jump:
		parent.input_buffer_timer.start()
		parent.buffered_input = "jump"

	# If the player releases jump before the jump apex, clip the upwards velocity for a shorter jump.
	if Input.is_action_just_released("player_jump") && parent.velocity.y < parent.JUMP_CLIP_VELOCITY:
		parent.velocity.y = parent.JUMP_CLIP_VELOCITY

	var direction: float = Input.get_axis("player_left", "player_right")
	if direction:
		parent.set_facing_direction(direction)
		parent.velocity.x = direction * parent.speed
	else:
		parent.velocity.x = move_toward(parent.velocity.x, 0, parent.speed)
