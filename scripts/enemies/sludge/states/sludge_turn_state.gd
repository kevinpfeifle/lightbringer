class_name SludgeTurnState
extends State

@export var pause_timer: Timer

func _ready() -> void:
	state_name = "turn"

func enter(args: Array) -> void:
	super(args)
	pause_timer.timeout.connect(_on_pause_timer_timeout)
	parent.direction_component.flip_direction()
	pause_timer.start()

func exit(next_state: StringName) -> void:
	super(next_state)
	pause_timer.timeout.disconnect(_on_pause_timer_timeout)

func _on_pause_timer_timeout():
	transition.emit("move", [state_name])