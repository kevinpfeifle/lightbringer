class_name Enemy
extends CharacterBody2D

@export var animation_player: AnimationPlayer
@export var health_component: HealthComponent

func _ready() -> void:
	animation_player.play("alive")
	health_component.dead.connect(_on_dead)

func _on_dead():
	animation_player.play("death")
