class_name GravityComponent
extends Node

@export var gravity: float = 980.0
@export var gravity_vector: Vector2 = Vector2(0, 1)

func handle_gravity(parent: CharacterBody2D, delta: float, is_falling: bool = false, is_jumping: bool = false) -> void:
	if !parent.is_on_floor():
		if is_falling:
			# Gravity will get stronger when falling. Jumping has normal gravity.
			parent.velocity += gravity_vector * (gravity * 2) * delta
		elif is_jumping:
			# Gravity will get slighty stronger when jumping to counteract the sudden impulse required for a punchy, fast jump.
			parent.velocity += gravity_vector * (gravity * 1.5) * delta
		else:
			parent.velocity += gravity_vector * gravity * delta