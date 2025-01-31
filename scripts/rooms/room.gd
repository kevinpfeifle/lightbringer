class_name Room
extends Node2D

@export var player: Player
@export var camera: Camera

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
	scene_transition.transition_finished.connect(_on_transition_finished)
	for door in doors:
		door.body_entered.connect(_handle_room_transition.bind(door))
	enter_room()

func enter_room() -> void:
	print(adjacent_rooms)
	print(WorldGlobals.current_room)
	print(WorldGlobals.last_room)
	WorldGlobals.current_room = scene_path
	var index: int = adjacent_rooms.find(WorldGlobals.last_room, 0)
	if index >= 0:
		var spawn_point = spawn_points[index]
		var door_side = door_sides[index]
		player.global_position = spawn_point.global_position
		if door_side == DoorDirection.LEFT:
			player.direction_component.set_direction_from_int(1)
		if door_side == DoorDirection.RIGHT:
			player.direction_component.set_direction_from_int(-1)
		if door_side == DoorDirection.BOTTOM:
			pass # Handle scenario where player has to be "jumped up"
		# door_side = door_sides[index]
	camera.reset_smoothing()
	camera.force_update_scroll()
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
		var packed_scene = PackedScene.new()
		packed_scene.pack(get_tree().current_scene)
		WorldGlobals.last_room = scene_path
		get_tree().change_scene_to_file(next_room)
