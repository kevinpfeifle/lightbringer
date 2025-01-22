class_name PlayerHurtState
extends PlayerState

const DAMPING_SPEED: float = 5.0

func _ready() -> void:
	state_name = "hurt"

## Args[1] should be the direction of the source of damage as a Vector2.
func enter(args: Array) -> void:
	super(args)
	parent.knockback_timer.timeout.connect(_on_knockback_timer_timeout)
	parent.animation_player.play("hurt")
	parent.animation_player.queue("idle")
	_handle_knockback(args[1])

func physics_update(delta) -> void:
	super(delta)
	parent.velocity.x = lerp(parent.velocity.x, 0.0, DAMPING_SPEED * delta)
	parent.velocity.y = lerp(parent.velocity.y, 0.0, DAMPING_SPEED * delta)

func _handle_knockback(direction: Vector2) -> void:
	parent.is_knocked_back = true
	parent.knockback_timer.start()

	var knockback_strength = 1500.0  # Adjust as needed
	var knockback_direction = 0

	if direction.x >= 0:
		knockback_direction = 1
	else:
		knockback_direction = -1

	parent.velocity.x = knockback_direction * knockback_strength
	parent.velocity.y = -1000

func _on_knockback_timer_timeout() -> void:
	parent.is_knocked_back = false