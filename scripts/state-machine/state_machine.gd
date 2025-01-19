class_name StateMachine
extends Node

@export var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transition.connect(on_child_transition)
		else:
			push_warning("StateMachine contains child which is not 'State'")
			
	current_state.active = true
	current_state.enter([]) # initial state

func _process(delta) -> void:
	current_state.update(delta)
		
func _physics_process(delta) -> void:
	current_state.physics_update(delta)

## This signal handles the logic of state transition.
func on_child_transition(new_state: StringName, args: Array) -> void:
	var next_state = states.get(new_state.to_lower())
	if (next_state != null and next_state != current_state):
		# Exit the current state and block its process functions.
		current_state.active = false
		current_state.exit(new_state)
		# Enter the new state and unblock its process functions.
		current_state = next_state
		next_state.active = true
		next_state.enter(args)
	else:
		push_warning("Called transition on a state that does not exist", new_state)
