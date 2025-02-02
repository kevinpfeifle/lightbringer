class_name LightHarvester
extends Boss

@export var speed: int
@export var starting_direction: DirectionComponent.Direction = DirectionComponent.Direction.LEFT
@export var nav_agent: NavigationAgent2D
@export var gravity_component: GravityComponent
@export var sprite: Sprite2D

@export_group("Detection Boxes")
@export var above_detection_box: Area2D
@export var front_detection_box: Area2D

@export_group("Hurtboxes")
@export var above_hurtbox: Area2D
@export var front_hurtbox: Area2D

@export_group("Timers")
@export var attack_timer: Timer
@export var attack_reset_timer: Timer

@export_group("State Machine")
@export var state_machine: StateMachine

var attack_direction: String

func _ready() -> void:
	above_detection_box.body_entered.connect(_on_body_entered_above_detection_box)
	front_detection_box.body_entered.connect(_on_body_entered_front_detection_box)
	direction_component.direction_changed.connect(_on_direction_changed)
	direction_component.current_direction = starting_direction

func _physics_process(delta: float) -> void:
	var is_falling = state_machine.current_state.state_name == "fall"
	var is_jumping = state_machine.current_state.state_name == "jump"
	gravity_component.handle_gravity(self, delta, is_falling, is_jumping)
	move_and_slide()

func _on_body_entered_above_detection_box(body: Node2D):
	if body is Player && attack_reset_timer.is_stopped():
		attack_direction = "above"
		state_machine.current_state.transition.emit("attack", [state_machine.current_state.state_name,])

func _on_body_entered_front_detection_box(body: Node2D):
	if body is Player && attack_reset_timer.is_stopped():
		attack_direction = "front"
		state_machine.current_state.transition.emit("attack", [state_machine.current_state.state_name])

func _on_direction_changed() -> void:
	if direction_component.current_direction == direction_component.Direction.RIGHT:
		sprite.scale.x = -1
		front_hurtbox.scale.x = -1
		above_hurtbox.scale.x = -1
		front_detection_box.scale.x = -1
		above_detection_box.scale.x = -1
	elif direction_component.current_direction == direction_component.Direction.LEFT:
		sprite.scale.x = 1
		front_hurtbox.scale.x = 1
		above_hurtbox.scale.x = 1
		front_detection_box.scale.x = 1
		above_detection_box.scale.x = 1

func _on_death() -> void:
	state_machine.current_state.transition.emit("death", [state_machine.current_state.state_name])