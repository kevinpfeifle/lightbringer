class_name TitleScreen
extends Control

@export var begin_button: Sprite2D
@export var animation_player: AnimationPlayer
@export var game_manager: GameManager

var clicked: bool = false

func _on_begin_button_area_mouse_exited() -> void:
	if !clicked:
		animation_player.play("hide_arrows")

func _on_begin_button_area_mouse_entered() -> void:
	if !clicked:
		animation_player.play("show_arrows")

func _on_begin_button_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT && !clicked:
			clicked = true
			animation_player.animation_finished.connect(_on_animation_finished)
			animation_player.play("fade")

func _on_animation_finished(anim_name: StringName):
	if anim_name == "fade":
		animation_player.animation_finished.disconnect(_on_animation_finished)
		game_manager.start_game() # Replace with function body.
		queue_free()
