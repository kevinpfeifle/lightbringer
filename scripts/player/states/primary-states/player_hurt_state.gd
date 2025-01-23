class_name PlayerHurtState
extends PlayerState

const DAMPING_SPEED: float = 5.0

var state_locked: bool = false

func _ready() -> void:
	state_name = "hurt"

## Args[1] should be the direction of the source of damage as a Vector2.
func enter(args: Array) -> void:
	super(args)
	state_locked = true
	parent.hurt_timer.timeout.connect(_on_hurt_timer_timeout)
	_handle_knockback(args[1])

func exit(new_state) -> void:
	super(new_state)
	parent.hurt_timer.timeout.disconnect(_on_hurt_timer_timeout)

func physics_update(delta) -> void:
	# Block checking for other states until the knockback timer has completed.
	if !state_locked:
		super(delta)
	parent.velocity.x = lerp(parent.velocity.x, 0.0, DAMPING_SPEED * delta)

func _handle_knockback(direction: Vector2) -> void:
	parent.is_hurt = true
	parent.hurt_timer.start()

	var knockback_strength = 1500.0  # Adjust as needed
	var knockback_direction = 0

	if direction.x >= 0:
		knockback_direction = 1
	else:
		knockback_direction = -1

	parent.velocity.x = knockback_direction * knockback_strength
	parent.velocity.y = -350

func _on_hurt_timer_timeout() -> void:
	parent.is_hurt = false
	state_locked = false