class_name DirectionComponent
extends Node

enum Direction { LEFT, RIGHT, UNKNOWN }

signal direction_changed()

var current_direction: Direction:
	set(new_direction):
		current_direction = new_direction
		direction_changed.emit()

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
	direction_changed.emit()

func flip_direction() -> void:
	if current_direction == Direction.LEFT:
		current_direction = Direction.RIGHT
	elif current_direction == Direction.RIGHT:
		current_direction = Direction.LEFT
	direction_changed.emit()