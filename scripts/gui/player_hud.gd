class_name PlayerHUD
extends Control

@export var health_pool_animation_player: AnimationPlayer
@export var player: Player

func _ready() -> void:
	health_pool_animation_player.play("full_health")

func _process(_delta):
	if player.health_component.current_health == 5:
		health_pool_animation_player.play("full_health")
	elif player.health_component.current_health == 4:
		health_pool_animation_player.play("4_health")
	elif player.health_component.current_health == 3:
		health_pool_animation_player.play("3_health")
	elif player.health_component.current_health == 2:
		health_pool_animation_player.play("2_health")
	elif player.health_component.current_health == 1:
		health_pool_animation_player.play("1_health")
	else:
		health_pool_animation_player.play("dead")
