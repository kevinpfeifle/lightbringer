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
	add_to_group("beacons")
	animation_player.play("unlit")

func light() -> void:
	var beacon_already_lit: bool = false
	if current_state == BeaconState.OFF:
		if WorldGlobals.lit_beacons.find(WorldGlobals.current_room) != -1:
			beacon_already_lit = true
		var enemies: Array = get_tree().get_nodes_in_group("enemies")
		if !beacon_already_lit && len(enemies) > 0:
			animation_player.play("blocked")
			animation_player.queue("off")
		else:
			if WorldGlobals.lit_beacons.find(WorldGlobals.current_room) == -1:
				WorldGlobals.lit_beacons.append(WorldGlobals.current_room)
			current_state = BeaconState.ON
			if !beacon_already_lit:
				animation_player.play("lighting")
				animation_player.queue("lit")
			else:
				animation_player.play("lit")
			beacon_lit.emit(self)

func _on_body_entered_light_aura(body: Node2D) -> void:
	if body is Player:
		var player: Player = body
		player.in_light_source = true
		player.in_beacon = true
		player.beacon_timer.start()

func _on_body_exited_light_aura(body: Node2D) -> void:
	if body is Player:
		var player: Player = body
		player.in_light_source = false
		player.in_beacon = false