class_name Room
extends Node2D

@export var camera: Camera
@export var default_spawn_location: Marker2D
@export var player_hud: PlayerHUD

## The indeces of these arrays need to line up so that they can be associated with one another.
@export_group("Scene Transitions")
@export var scene_path: String
@export var scene_transition: SceneTransition
@export var adjacent_rooms: Array[String] = [] # These Strings are meant to be resource paths to those rooms.
@export var doors: Array[Area2D] = []
@export var door_sides: Array[DoorDirection] = []
@export var spawn_points: Array[Marker2D] = []

enum DoorDirection { LEFT, RIGHT, TOP, BOTTOM }

var next_room: String

func _ready() -> void:
	# Handle setting the player in the room.
	if GlobalPlayer.player == null:
		push_error("Player not found in PlayerGlobal, was it initialized?")
		return

	if GlobalPlayer.player.get_parent():
		GlobalPlayer.player.get_parent().remove_child(GlobalPlayer.player)

	# If there's already a player, remove any existing one and use the global one
	# var existing_player = get_node_or_null("Player")
	# if existing_player:
	# 	existing_player.queue_free()
	add_child(GlobalPlayer.player)
	GlobalPlayer.player.global_position = default_spawn_location.global_position
		
	scene_transition.transition_finished.connect(_on_transition_finished)
	for door in doors:
		door.body_entered.connect(_handle_room_transition.bind(door))
	
	enter_room()

func enter_room() -> void:
	WorldGlobals.current_room = scene_path
	var index: int = adjacent_rooms.find(WorldGlobals.last_room, 0)
	if index >= 0:
		var spawn_point = spawn_points[index]
		var door_side = door_sides[index]
		GlobalPlayer.player.global_position = spawn_point.global_position
		if door_side == DoorDirection.LEFT:
			GlobalPlayer.player.direction_component.set_direction_from_int(1)
		if door_side == DoorDirection.RIGHT:
			GlobalPlayer.player.direction_component.set_direction_from_int(-1)
		if door_side == DoorDirection.BOTTOM:
			pass # Handle scenario where player has to be "jumped up"
		# door_side = door_sides[index]

	# Handle setting the camera to the player.
	if camera:
		camera.get_parent().remove_child(camera)  # Remove from old parent
		GlobalPlayer.player.add_child(camera)  # Attach to the player
		camera.position = Vector2.ZERO  # Reset its local position
		camera.global_position = GlobalPlayer.player.global_position  # Reset its local position
		camera.make_current()
		camera.reset_smoothing()
		camera.force_update_scroll()

	# Remove any previously killed enemies.
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if WorldGlobals.is_enemy_defeated(scene_path, enemy.enemy_id):
			enemy.queue_free()

	# Light an previously lit beacons.
	for beacon in get_tree().get_nodes_in_group("beacons"):
		if WorldGlobals.lit_beacons.find(WorldGlobals.current_room) != -1:
			beacon.light()

	# Update the camera and UI, and fade in.
	camera.reset_smoothing()
	camera.force_update_scroll()
	GlobalPlayer.player.reconnect_deplete_signal()
	player_hud.update_health_bar()
	player_hud.set_light_markers()
	scene_transition.fade_in()

func exit_room() -> void:
	scene_transition.fade_out()

func transition_rooms(door: Area2D):
	var index: int = doors.find(door, 0)
	if index >= 0:
		next_room = adjacent_rooms[index]
		# door_side = door_sides[index]
		exit_room()

func _handle_room_transition(body: Node2D, door: Area2D) -> void:
	if body is Player:
		transition_rooms(door)

func _on_transition_finished(transition: String) -> void:
	if transition == "fade_in":
		# Re-enable player control
		return
	elif transition == "fade_out":
		# Disable player control
		if GlobalPlayer.player and GlobalPlayer.player.get_parent():
			GlobalPlayer.player.reparent(get_tree().root)  # Move it to root

		var packed_scene = PackedScene.new()
		packed_scene.pack(get_tree().current_scene)
		WorldGlobals.last_room = scene_path
		get_tree().change_scene_to_file(next_room)
