class_name OrbiHurtState
extends State

var last_state: String
var state_locked: bool = false

func _ready() -> void:
	state_name = "hurt"

## Args[1] should be the direction of the source of damage as an Vector2i.
func enter(args) -> void:
	super(args)
	parent.is_hurt = true
	last_state = args[0]
	state_locked = true
	parent.knockback_component.knockback_finished.connect(_on_knockback_finished)
	# For a standard hurt knockback, we always want a small amount of upward knockback, so pass -1 for vert_direction.
	parent.knockback_component.handle_knockback(parent.hurt_timer, args[1], 500.0, 500.0)

func exit(new_state) -> void:
	super(new_state)
	parent.knockback_component.knockback_finished.disconnect(_on_knockback_finished)

func physics_update(delta) -> void:
	# Block checking for other states until the knockback timer has completed.
	if !state_locked:
		super(delta)

func _on_knockback_finished() -> void:
	parent.is_hurt = false
	state_locked = false
	transition.emit(last_state, [state_name])
