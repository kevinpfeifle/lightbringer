class_name PlayerState
extends State

## PlayerState is an abstract class. It shouldn't be attached to any Nodes.

## skip_state allows us to block state logic in the event we are routed to a buffered input instead.
## This is needed because there will be a frame or so where we enter that state that would have occurred
## before we can enter the buffered one.
var skip_state: bool = false

## The buffer_map dictates what states a buffered input can fire from.
var buffer_map: Dictionary = {
	"jump": ["idle", "move"]
}

func enter(args) -> void:
	super(args)

	# Check if there is a buffered input we should transition to instead of this state.
	skip_state = false
	if parent.buffered_input != "" && buffer_map[parent.buffered_input].has(state_name):
		var new_state = parent.buffered_input
		parent.input_buffer_timer.stop()
		parent.buffered_input = ""
		skip_state = true
		transition.emit(new_state, [state_name])

## Default abstract logic simply handles state changes.
func physics_update(delta: float) -> void:
	super(delta)

	if parent.is_knocked_back:
		return
	else:
		var new_state = _check_for_state_change()
		if new_state != state_name && new_state != "":
			transition.emit(new_state, [state_name]) # All states get the previous state sent as first arg.

## Returns the name of the next state based on user input actions. Empty string = no change.
func _check_for_state_change() -> StringName:
	if !parent.is_on_floor() && parent.velocity.y >= 0:
		return "fall"
	elif parent.is_on_floor() && Input.is_action_just_pressed("player_jump"):
		return "jump"
	elif parent.is_on_floor() && Input.get_axis("player_left", "player_right") != 0:
		return "move"
	elif parent.is_on_floor() && parent.velocity == Vector2.ZERO:
		return "idle"
	
	return ""
