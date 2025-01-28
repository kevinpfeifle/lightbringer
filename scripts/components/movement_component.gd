class_name MovementComponent
extends Node

@export var parent: CharacterBody2D
@export var flying_body: bool = false

var velocity: Vector2

func _ready() -> void:
	velocity = Vector2.ZERO

func handle_movement() -> void:
	if flying_body:
		parent.velocity = velocity
	else:
		parent.velocity.x = velocity.x
