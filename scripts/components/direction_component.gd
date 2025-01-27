class_name DirectionComponent
extends Node

enum Direction { LEFT, RIGHT, UNKNOWN }

var current_direction: Direction

func _convert_direction_to_int(direction: Direction) -> int:
	if direction == Direction.LEFT:
		return -1
	elif direction == Direction.RIGHT:
		return 1
	else:
		return 0 # Unknown direction.

func get_direction_as_int() -> int:
	return _convert_direction_to_int(current_direction)

func set_direction_from_int(direction: int) -> void:
	if direction == -1:
		current_direction = Direction.LEFT
	elif direction == 1:
		current_direction = Direction.RIGHT
	else:
		current_direction = Direction.UNKNOWN