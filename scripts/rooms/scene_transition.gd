class_name SceneTransition
extends Control

@export var animation_player: AnimationPlayer

signal transition_finished(transition: String)

func _ready() -> void:
	animation_player.animation_finished.connect(_animation_finished)

func fade_in() -> void:
	animation_player.play("fade_in")

func fade_out() -> void:
	animation_player.play("fade_out")

func _animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		transition_finished.emit("fade_in")
	elif anim_name == "fade_out":
		transition_finished.emit("fade_out")