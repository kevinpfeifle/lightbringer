class_name PlayerDeathState
extends PlayerState

const DEATH_DAMPING_SPEED: float = 5.0

func _ready() -> void:
	state_name = "death"

func enter(args: Array) -> void:
	super(args)

	## TODO: Find a better/more modular way to do this. Need to disable all colisions with enemies.
	parent.set_collision_mask_value(3, false)
	
	parent.animation_player.play("death")
	parent.animation_player.queue("death_linger")

## Override the inherited version that handles state checking since we won't transition out of this state.
func physics_update(delta: float) -> void:
	parent.velocity.x = lerp(parent.velocity.x, 0.0, DEATH_DAMPING_SPEED * delta)