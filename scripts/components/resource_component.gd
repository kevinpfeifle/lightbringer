class_name ResourceComponent
extends Node

@export var resource_name: String
@export var max_resource: float

signal consumed(amount: float) # Alert consumeres that a resource was consumed.
signal depleted() # Alert consumers that there is no more remaining resource.
signal overflowed(overflow_amount: float) # Alert consumers that the resource overflowed. Used in the UI.
signal resource_reset() # Alert consumers that the resource was reset to its max.
signal restored(amount_restored: float, residual_amount: float) # ALert consumers that an amount of resource was restored.

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
		current_resource = clamp(current_resource, 0, max_resource) # Make sure it isn't below 0.
		consumed.emit(amount)
		if current_resource == 0:
			depleted.emit()

## Overflow is used for when the resource exceeds its max. Niche use cases, Wick's light is an example.
func overflow(overflow_amount: float) -> void:
	current_resource = overflow_amount
	overflowed.emit(overflow_amount)

func reset() -> void:
	current_resource = max_resource
	resource_reset.emit()

func restore(amount_restored: float) -> void:
	current_resource += amount_restored
	var residual_amount = current_resource - max_resource
	if residual_amount < 0:
		residual_amount = 0 # There is no residual if we currently have less than max after adding.
	current_resource = clamp(current_resource, 0, max_resource) # Make sure it isn't above the max.
	restored.emit(amount_restored, residual_amount)

func unblock_resource() -> void:
	resource_depletion_blocked = false

func full_resource() -> bool:
	return current_resource == max_resource