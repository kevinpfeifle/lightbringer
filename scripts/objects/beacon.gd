class_name Beacon
extends StaticBody2D

@export var state: BeaconState = BeaconState.OFF
@export var animation_player: AnimationPlayer
@export var light_aura: Area2D

enum BeaconState { OFF, ON }

signal beacon_lit(beacon: Beacon)

var current_state: int

func _ready() -> void:
	light_aura.body_entered.connect(_on_body_entered_light_aura)
	light_aura.body_exited.connect(_on_body_exited_light_aura)
	current_state = state
	animation_player.play("unlit")

func light() -> void:
	if current_state == BeaconState.OFF:
		var enemies: Array = get_tree().get_nodes_in_group("enemies")
		if len(enemies) > 0:
			animation_player.play("blocked")
			animation_player.queue("off")
		else:
			current_state = BeaconState.ON
			animation_player.play("lighting")
			animation_player.queue("lit")
			beacon_lit.emit(self)

func _on_body_entered_light_aura(body: Node2D) -> void:
	if body is Player:
		var player: Player = body
		player.in_light_source = true

func _on_body_exited_light_aura(body: Node2D) -> void:
	if body is Player:
		var player: Player = body
		player.in_light_source = false