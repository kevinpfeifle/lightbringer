class_name PlayerReadyState
extends State

## ReadyState is the passive state for the secondary state machine. It simply checks if it should
## transition into one of the active states, like AttackState. It functions like the logic built
## into the PlayerState abstract class.

func _ready() -> void:
	state_name = "ready"

func exit(new_state) -> void:
	super(new_state)
	parent.camera.center_camera()

## Default abstract logic simply handles state changes.
func physics_update(delta: float) -> void:
	super(delta)
	if parent.is_hurt:
		return
	else:
		var new_state = _check_for_state_change()
		if new_state != state_name && new_state != "":
			transition.emit(new_state, [state_name]) # All states get the previous state sent as first arg.

## Returns the name of the next state based on user input actions. Empty string = no change.
func _check_for_state_change() -> StringName:
	if Input.is_action_just_pressed("player_attack") && parent.primary_state_machine.current_state.state_name != "glowing":
		return "attack"
	
	return ""