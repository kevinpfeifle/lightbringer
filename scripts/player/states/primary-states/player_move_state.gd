class_name PlayerMoveState
extends PlayerState

func _ready() -> void:
	state_name = "move"

func physics_update(delta) -> void:
	super(delta)

	if !parent.is_hurt:
		var direction: float = Input.get_axis("player_left", "player_right")
		if direction:
			parent.set_facing_direction(direction)
			parent.velocity.x = direction * parent.speed
		else:
			parent.velocity.x = move_toward(parent.velocity.x, 0, parent.speed)