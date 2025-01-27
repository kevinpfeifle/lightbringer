class_name Orbi
extends Enemy

@export var chase_area: Area2D
@export var chase_speed: float
@export var detection_area: Area2D
@export var home_point: Marker2D
@export var nav_agent: NavigationAgent2D
@export var speed: float
@export var state_machine: StateMachine
@export var wander_timer: Timer # A timer for 5 seconds, it is the max wander duration.
@export var wander_area: Area2D
@export var wait_timer: Timer # A timer for how long to wait between wanders. Max 5 seconds.

var is_hurt: bool = false
var player_detected: bool = false
var player_noticed: bool = false

func _ready() -> void:
	super()
	chase_area.body_entered.connect(_on_chase_area_entered)
	chase_area.body_exited.connect(_on_chase_area_exited)
	detection_area.body_entered.connect(_on_detection_area_entered)
	detection_area.body_exited.connect(_on_detection_area_exited)

func _physics_process(_delta: float) -> void:
	move_and_slide()
	knockback_component.handle_knockback_decay(0.1)

func _on_damaged(_amount: float, _source: Node, _power: int, direction: Vector2):
	knockback_component.initialize_knockback(direction)

func _on_chase_area_entered(body: Node2D) -> void:
	if body is Player:
		player_detected = true

func _on_chase_area_exited(body: Node2D) -> void:
	if body is Player:
		player_detected = false

func _on_detection_area_entered(body: Node2D) -> void:
	if body is Player:
		player_noticed = true
		if state_machine.current_state.state_name != "chase":
			state_machine.current_state.transition.emit("chase", [state_machine.current_state.state_name, body])

func _on_detection_area_exited(body: Node2D) -> void:
	if body is Player:
		player_noticed = false