class_name Camera
extends Camera2D

var origin: Vector2
var target_offset: Vector2

func _ready() -> void:
	origin = offset
	print(global_position)
	# Force the camera to align with its limits
	if position_smoothing_enabled: 
		# If using smoothing, update immediately
		reset_smoothing()
	force_update_scroll()

func _process(delta) -> void:
	offset = offset.move_toward(target_offset, 800 * delta)
	# print(offset)
	# print(global_position)

func _pan_camera(distance) -> void:
	target_offset = distance

func center_camera() -> void:
	target_offset = origin

func look_up() -> void:
	_pan_camera(Vector2(0, -200))

func look_down() -> void:
	_pan_camera(Vector2(0, 200))