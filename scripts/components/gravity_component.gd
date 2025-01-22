class_name GravityComponent
extends Node

@export var gravity: float = 980.0
@export var gravity_vector: Vector2 = Vector2(0, 1)

var air_time: float = 0.0

func handle_gravity(parent: CharacterBody2D, delta: float, is_falling: bool) -> void:
	if !parent.is_on_floor():
		if is_falling:
			# Gravity will get stronger the longer the fall.
			parent.velocity += gravity_vector * gravity * delta * (1.25 + air_time)
			air_time += delta * 2
		else:
			parent.velocity += gravity_vector * gravity * delta
	else:
		air_time = 0.0