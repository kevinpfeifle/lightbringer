class_name Enemy
extends CharacterBody2D

@export var animation_player: AnimationPlayer
@export var health_component: HealthComponent
@export var knockback_component: KnockbackComponent

func _ready() -> void:
	health_component.damaged.connect(_on_damaged)
	health_component.dead.connect(_on_dead)

## Implement in the child class.
func _on_damaged(_amount: float, _source: Node, _power: int, _direction: Vector2):
	pass

func _on_dead():
	animation_player.play("death")
