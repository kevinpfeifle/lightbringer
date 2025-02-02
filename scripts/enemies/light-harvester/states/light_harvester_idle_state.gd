class_name LightHarvesterIdleState
extends State

func _ready() -> void:
	state_name = "idle"

func enter(args: Array):
	super(args)
	parent.velocity = Vector2.ZERO
