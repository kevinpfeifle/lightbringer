class_name SludgeMoveState
extends State

@export var floor_checker_left: RayCast2D
@export var floor_checker_right: RayCast2D
@export var wall_checker_left: RayCast2D
@export var wall_checker_right: RayCast2D

func _ready() -> void:
	state_name = "move"

func physics_update(delta) -> void:
	super(delta)

	if parent.is_on_floor():
		var active_floor_checker: RayCast2D
		var active_wall_checker: RayCast2D
		if parent.direction_component.current_direction == parent.direction_component.Direction.LEFT:
			active_floor_checker = floor_checker_left
			active_wall_checker = wall_checker_left
		elif parent.direction_component.current_direction == parent.direction_component.Direction.RIGHT:
			active_floor_checker = floor_checker_right
			active_wall_checker = wall_checker_right

		if active_floor_checker.is_colliding() && !active_wall_checker.is_colliding():
			var direction = parent.direction_component.get_direction_as_int()
			parent.movement_component.velocity.x = direction * parent.speed
		else:
			# Handle flipping Sludge and turning around.
			parent.movement_component.velocity.x = 0
			transition.emit("turn", [state_name])
