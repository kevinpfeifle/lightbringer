class_name KnockbackComponent
extends Node

@export var body: CharacterBody2D
@export var default_decay_weight: float = 1.0
@export var default_impulse: Vector2 = Vector2(700.0, 550.0)

var knockback: Vector2 = Vector2.ZERO

func initialize_knockback(direction: Vector2, impulse: Vector2 = default_impulse) -> void:
	knockback = direction.normalized() * impulse

func handle_knockback(parent: CharacterBody2D) -> void:
	parent.velocity += knockback

## decay_weight must be a float between 0.0 and 1.0.
func handle_knockback_decay(decay_weight: float = default_decay_weight):
	knockback = lerp(knockback, Vector2.ZERO, decay_weight)
