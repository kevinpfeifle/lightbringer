class_name PlayerIdleState
extends PlayerState

func _ready() -> void:
	state_name = "idle"

func physics_update(delta):
	super(delta)
	parent.velocity.x = move_toward(parent.velocity.x, 0, parent.speed)