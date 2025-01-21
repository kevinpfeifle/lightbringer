class_name PlayerIdleState
extends PlayerState

func _ready() -> void:
	state_name = "idle"

func enter(args: Array) -> void:
	super(args)
	if !skip_state:
		parent.animation_player.queue("idle")

func exit(new_state) -> void:
	super(new_state)
	parent.animation_player.stop()
