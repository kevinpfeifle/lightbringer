class_name PlayerDeathState
extends PlayerState

const DEATH_DAMPING_SPEED: float = 5.0

func _ready() -> void:
	state_name = "death"

func enter(args: Array) -> void:
	super(args)
	parent.alive = false

	## TODO: Find a better/more modular way to do this. Need to disable all colisions with enemies.
	parent.set_collision_mask_value(3, false)

## Override the inherited version that handles state checking since we won't transition out of this state.
func physics_update(_delta: float) -> void:
	parent.velocity = Vector2(0, 0)
	## TODO: BLOCK ALL PHYSICS INTERACTIONS
	# set_physics_process(false)