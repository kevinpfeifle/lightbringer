class_name State
extends Node

## State is an abstract class. It shouldn't be attached to any Nodes.

@warning_ignore("unused_signal") # The children of State consume this. 
signal transition(new_state: StringName)

var active: bool = false
var parent: CharacterBody2D
var state_name: StringName

## The State's setup function.
func enter(_args: Array) -> void:
	if !active:
		return

## The State's breakdown function. A reference to the new state is passed to help with logic.
func exit(_new_state: StringName) -> void:
	pass

## Mimics _process for the State, and gets called by StateMachine if this is the active State.
func update(_delta: float) -> void:
	if !active:
		return
	
## Mimics _physics_process for the State, and gets called by StateMachine if this is the active State.
func physics_update(_delta: float) -> void:
	if !active:
		return