class_name Lantern
extends StaticBody2D

@export var state: LanternState = LanternState.OFF
@export var extinguish_timer: Timer
@export var light_aura: Area2D

enum LanternState { OFF, ON }

signal lantern_lit(lantern: Lantern)
signal lantern_extinguished(lantern: Lantern)

var current_state: int = LanternState.OFF

func _ready() -> void:
	extinguish_timer.timeout.connect(_extinguish)
	light_aura.body_entered.connect(_on_body_entered_light_aura)
	light_aura.body_exited.connect(_on_body_exited_light_aura)
	current_state = state

func _extinguish() -> void:
	current_state = LanternState.OFF
	lantern_extinguished.emit(self)

func light() -> void:
	current_state = LanternState.ON
	lantern_lit.emit(self)
	extinguish_timer.start()

func _on_body_entered_light_aura(body: Node2D) -> void:
	if body is Player:
		var player: Player = body
		player.in_light_source = true

func _on_body_exited_light_aura(body: Node2D) -> void:
	if body is Player:
		var player: Player = body
		player.in_light_source = false
