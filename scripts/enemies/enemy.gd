class_name Enemy
extends CharacterBody2D

@export var animation_player: AnimationPlayer

func _ready() -> void:
	animation_player.play("alive")