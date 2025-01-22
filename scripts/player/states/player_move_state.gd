class_name PlayerMoveState
extends PlayerState

func _ready() -> void:
	state_name = "move"

func enter(args: Array) -> void:
	super(args)
	if !skip_state:
		parent.speed_changed.connect(_on_speed_changed)
		if parent.running:
			parent.animation_player.play("run_start")
			parent.animation_player.queue("run")
		else:
			parent.animation_player.queue("walk")

func exit(new_state: StringName) -> void:
	super(new_state)
	parent.speed_changed.disconnect(_on_speed_changed)
	if new_state == "idle":
		if parent.animation_player.current_animation == "walk":
			parent.animation_player.stop()
		else:
			parent.animation_player.play("run_stop")

func physics_update(delta) -> void:
	super(delta)

	if !parent.is_knocked_back:
		var direction: float = Input.get_axis("player_left", "player_right")
		if direction:
			parent.set_facing_direction(direction)
			parent.velocity.x = direction * parent.speed
		else:
			parent.velocity.x = move_toward(parent.velocity.x, 0, parent.speed)

func _on_speed_changed(running: bool) -> void:
	if running:
		parent.animation_player.play("run_start")
		parent.animation_player.queue("run")
	else:
		parent.animation_player.play("run_stop")
		parent.animation_player.queue("walk")