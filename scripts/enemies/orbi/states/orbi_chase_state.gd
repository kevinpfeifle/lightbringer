class_name OrbiChaseState
extends State

func _ready() -> void:
	state_name = "chase"

func enter(args) -> void:
	super(args)

func exit(new_state) -> void:
	super(new_state)


func physics_update(delta) -> void:
	super(delta)