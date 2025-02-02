class_name LightHarvesterDeathState
extends State

func _ready() -> void:
	state_name = "death"

func physics_update(_delta):
	parent.velocity = Vector2.ZERO