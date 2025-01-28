class_name ResourceComponent
extends Node

@export var resource_name: String
@export var max_resource: float

signal consumed(amount: float) # Alert consumeres that a resource was consumed.
signal depleted() # Alert consumers that there is no more remaining resource.
signal resource_reset() # Alert consumers that the resource was reset to its max.
signal restored(amount: float) # ALert consumers that an amount of resource was restored.

var current_resource: float
var resource_depletion_blocked: bool

func _ready() -> void:
	current_resource = max_resource

func block_resource() -> void:
	resource_depletion_blocked = true

func can_consume() -> bool:
	return !(current_resource == 1 && resource_depletion_blocked)

func consume(amount: float) -> void:
	if current_resource > 0:
		current_resource -= amount
		clamp(current_resource, 0, max_resource) # Make sure it isn't below 0.
		consumed.emit(amount)
		if current_resource == 0:
			depleted.emit()

func reset() -> void:
	current_resource = max_resource
	resource_reset.emit()

func restore(amount: float) -> void:
	current_resource += amount
	clamp(current_resource, 0, max_resource) # Make sure it isn't above the max.
	restored.emit(amount)

func unblock_resource() -> void:
	resource_depletion_blocked = false