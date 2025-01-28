class_name PlayerJumpState
extends PlayerState

const JUMP_CLIP_VELOCITY: float = -10.0

var jump_action: String = "player_jump"

func _ready() -> void:
	state_name = "jump"

# args[0] is the previous state, args[1] is *perhaps* the secondary state, ie, attack.
func enter(args: Array) -> void:
	super(args)

	if len(args) == 2 && args[1] == "attack":
		jump_action = "player_attack" # Enables reusing this component as an attack "bounce jump"

	if Input.is_action_just_released(jump_action):
		parent.velocity.y = JUMP_CLIP_VELOCITY
	else:
		parent.velocity.y = parent.JUMP_VELOCITY

func exit(new_state) -> void:
	super(new_state)
	jump_action = "player_jump" # Ensure we reenable the normal jump functionality if this was an attack "bounce jump"

func physics_update(delta) -> void: 
	super(delta)
	parent.decrease_light()

	# Buffer the next jump if a player is attempting a new jump mid-jump. This might happen when platforming.
	var attempted_jump: bool = Input.is_action_just_pressed("player_jump")
	if attempted_jump:
		parent.input_buffer_timer.start()
		parent.buffered_input = "jump"

	# If the player releases jump before the jump apex, clip the upwards velocity for a shorter jump.
	if Input.is_action_just_released(jump_action):
		parent.velocity.y = JUMP_CLIP_VELOCITY

	var direction: float = Input.get_axis("player_left", "player_right")
	if direction:
		parent.direction_component.set_direction_from_int(direction)
		parent.velocity.x = direction * parent.speed
	else:
		parent.velocity.x = move_toward(parent.velocity.x, 0, parent.speed)
