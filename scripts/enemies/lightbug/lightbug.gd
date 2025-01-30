class_name Lightbug
extends CharacterBody2D

@export var light_amount: int = 2
@export var speed: float = 75.0
@export var starting_direction: DirectionComponent.Direction = DirectionComponent.Direction.LEFT

@export_group("Components")
@export var direction_component: DirectionComponent

@export_group("Pathfinding")
@export var follow_area: Area2D
@export var detection_area: Area2D
@export var home_point: Marker2D
@export var nav_agent: NavigationAgent2D
@export var wander_timer: Timer # A timer for 5 seconds, it is the max wander duration.
@export var wander_area: Area2D
@export var wait_timer: Timer # A timer for how long to wait between wanders. Max 5 seconds.

@export_group("Sprite")
@export var animation_player: AnimationPlayer
@export var sprite: Sprite2D

@export_group("State Machine")
@export var state_machine: StateMachine

var consumed: bool = false
var home: Vector2
var player_detected: bool = false
var player_noticed: bool = false

func _ready() -> void:
	direction_component.direction_changed.connect(_on_direction_changed)
	follow_area.body_entered.connect(_on_follow_area_entered)
	follow_area.body_exited.connect(_on_follow_area_exited)
	detection_area.body_entered.connect(_on_detection_area_entered)
	detection_area.body_exited.connect(_on_detection_area_exited)

	direction_component.current_direction = starting_direction
	home = home_point.global_position

func _physics_process(_delta: float) -> void:
	move_and_slide()

func _on_direction_changed() -> void:
	if direction_component.current_direction == direction_component.Direction.RIGHT:
		sprite.scale.x = -1
	elif direction_component.current_direction == direction_component.Direction.LEFT:
		sprite.scale.x = 1

func _on_follow_area_entered(body: Node2D) -> void:
	if body is Player:
		player_detected = true

func _on_follow_area_exited(body: Node2D) -> void:
	if body is Player:
		player_detected = false

func _on_detection_area_entered(body: Node2D) -> void:
	if body is Player:
		player_noticed = true
		if state_machine.current_state.state_name != "follow":
			state_machine.current_state.transition.emit("follow", [state_machine.current_state.state_name, body])

func _on_detection_area_exited(body: Node2D) -> void:
	if body is Player:
		player_noticed = false

func stun() -> void:
	velocity = Vector2.ZERO
	state_machine.current_state.transition.emit("stunned", [state_machine.current_state])

func consume() -> void:
	if !consumed:
		consumed = true
		state_machine.current_state.transition.emit("death", [state_machine.current_state])