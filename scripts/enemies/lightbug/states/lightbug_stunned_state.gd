class_name LightbugStunnedState
extends State

@export var stunned_timer: Timer

const LIGHTBUG_DEFAULT_COLLISION_LAYER: int = 6
const LIGHTBUG_OBJECT_COLLISION_LAYER: int = 5

func _ready() -> void:
	state_name = "stunned"

func enter(args: Array) -> void:
	super(args)
	stunned_timer.timeout.connect(_on_stunned_timer_timeout)
	parent.set_collision_layer_value(LIGHTBUG_DEFAULT_COLLISION_LAYER, false)
	parent.set_collision_layer_value(LIGHTBUG_OBJECT_COLLISION_LAYER, true)
	stunned_timer.start()

func exit(next_state: StringName) -> void:
	super(next_state)
	stunned_timer.timeout.disconnect(_on_stunned_timer_timeout)
	parent.set_collision_layer_value(LIGHTBUG_DEFAULT_COLLISION_LAYER, true)
	parent.set_collision_layer_value(LIGHTBUG_OBJECT_COLLISION_LAYER, false)

func physics_update(delta):
	super(delta)
	parent.velocity = Vector2.ZERO

func _on_stunned_timer_timeout():
	transition.emit("wander", [state_name])