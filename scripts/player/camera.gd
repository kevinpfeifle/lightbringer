class_name Camera
extends Camera2D

var origin: Vector2
var target_offset: Vector2

@export_group("CameraMovement")
@export var allow_horizontal_movement: bool = true
@export var allow_vertical_movement: bool = true

var initial_x_pos: float
var initial_y_pos: float

func _ready() -> void:
	initial_x_pos = global_position.x
	initial_y_pos = global_position.y
	origin = offset
	# Force the camera to align with its limits
	if position_smoothing_enabled: 
		# If using smoothing, update immediately
		reset_smoothing()
	force_update_scroll()

func _process(delta) -> void:
	if !allow_horizontal_movement:
		global_position.x = initial_x_pos
	if !allow_vertical_movement:
		global_position.y = initial_y_pos
	offset = offset.move_toward(target_offset, 800 * delta)

func _pan_camera(distance) -> void:
	target_offset = distance

func center_camera() -> void:
	target_offset = origin

func look_up() -> void:
	_pan_camera(Vector2(0, -200))

func look_down() -> void:
	_pan_camera(Vector2(0, 200))