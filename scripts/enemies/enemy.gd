class_name Enemy
extends CharacterBody2D

@export var animation_player: AnimationPlayer
@export var health_component: HealthComponent
@export var knockback_component: KnockbackComponent

func _ready() -> void:
	animation_player.play("alive")
	health_component.damaged.connect(_on_damage)
	health_component.dead.connect(_on_dead)
	if knockback_component:
		knockback_component.knockback_finished.connect(_on_knockback_finished)

## Implement in the child class.
func _on_knockback_finished():
	pass

## Implement in the child class.
func _on_damage():
	pass

func _on_dead():
	animation_player.play("death")
