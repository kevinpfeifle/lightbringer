class_name PlayerIdleState
extends PlayerState

@export var look_timer: Timer

enum LookDirection {UP, DOWN}

var direction: LookDirection

func _ready() -> void:
	state_name = "idle"
	look_timer.timeout.connect(_on_look_timer_timeout)

func update(_delta) -> void:
	if Input.is_action_just_pressed("player_up"):
		look_timer.start()
		direction = LookDirection.UP
	elif Input.is_action_just_released("player_up"):
		if !look_timer.is_stopped():
			look_timer.stop()
		else:
			parent.camera.center_camera()
	if Input.is_action_just_pressed("player_down"):
		look_timer.start()
		direction = LookDirection.DOWN
	elif Input.is_action_just_released("player_down"):
		if !look_timer.is_stopped():
			look_timer.stop()
		else:
			parent.camera.center_camera()

func physics_update(delta) -> void:
	super(delta)
	parent.velocity.x = move_toward(parent.velocity.x, 0, parent.speed)

func _on_look_timer_timeout() -> void:
	if direction == LookDirection.UP:
		parent.camera.look_up()
	elif direction == LookDirection.DOWN:
		parent.camera.look_down()
