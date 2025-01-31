extends Node

## Player location information
var current_room: String
var last_room: String

## Defeated Enemies dictionary
## Example: { "room1": [enemy_id_1, enemy_id2, etc...] }
var defeated_enemies: Dictionary = { }

## Array of room scene paths that had their beacon lit already.
var lit_beacons: Array = []

func is_enemy_defeated(scene_path: String, enemy_id: int):
	var scene_graveyard = defeated_enemies.get(scene_path)
	if scene_graveyard:
		if scene_graveyard.find(enemy_id) != -1:
			return true
		else:
			return false
	else:
		return false
