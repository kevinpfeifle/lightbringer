class_name Orbi
extends Enemy

@export var home_point: Marker2D
@export var nav_agent: NavigationAgent2D
@export var speed: float
@export var wander_timer: Timer # A timer for 5 seconds, it is the max wander duration.
@export var wander_area: Area2D
@export var wander_leash_distance: int
@export var wait_timer: Timer # A timer for how long to wait between wanders. Max 5 seconds.

func _physics_process(_delta: float) -> void:
	move_and_slide()