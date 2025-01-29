class_name Lightbug
extends CharacterBody2D

@export var speed: float = 75.0
@export var starting_direction: DirectionComponent.Direction = DirectionComponent.Direction.LEFT

@export_group("Components")
@export var direction_component: DirectionComponent

@export_group("Pathfinding")
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

var home: Vector2

func _ready() -> void:
	direction_component.direction_changed.connect(_on_direction_changed)
	direction_component.current_direction = starting_direction
	home = home_point.global_position

func _physics_process(_delta: float) -> void:
	move_and_slide()

func _on_direction_changed() -> void:
	if direction_component.current_direction == direction_component.Direction.RIGHT:
		sprite.scale.x = -1
	elif direction_component.current_direction == direction_component.Direction.LEFT:
		sprite.scale.x = 1
