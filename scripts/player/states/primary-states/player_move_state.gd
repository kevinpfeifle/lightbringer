class_name PlayerMoveState
extends PlayerState

func _ready() -> void:
	state_name = "move"

func enter(args: Array) -> void:
	super(args)

func physics_update(delta) -> void:
	super(delta)
	if parent.speed == parent.RUN_SPEED:
		parent.increase_light()
	elif parent.speed == parent.WALK_SPEED:
		parent.decrease_light()

	if !parent.is_hurt:
		var direction: float = Input.get_axis("player_left", "player_right")
		if direction:
			parent.direction_component.set_direction_from_int(direction)
			parent.velocity.x = direction * parent.speed
		else:
			parent.velocity.x = move_toward(parent.velocity.x, 0, parent.speed)