class_name LightbugDeathState
extends State

func _ready() -> void:
	state_name = "death"

func enter(args: Array):
	super(args)
	parent.movement_component.velocity = Vector2.ZERO