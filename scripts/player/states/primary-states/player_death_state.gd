class_name PlayerDeathState
extends PlayerState

const DEATH_DAMPING_SPEED: float = 5.0

func _ready() -> void:
	state_name = "death"

func enter(args: Array) -> void:
	super(args)
	parent.death_light()
	parent.alive = false
	parent.set_collision_mask_value(parent.ENEMY_COLLISION_LAYER, false) # Disable collisions with enemies.
	parent.respawn_timer.start()

## Override the inherited version that handles state checking since we won't transition out of this state.
func physics_update(_delta: float) -> void:
	parent.death_light()
	parent.velocity = Vector2(0, 0)
	## TODO: BLOCK ALL PHYSICS INTERACTIONS
	# set_physics_process(false)