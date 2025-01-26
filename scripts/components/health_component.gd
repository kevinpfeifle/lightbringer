class_name HealthComponent
extends Node

@export var i_frame_timer: Timer
@export var max_health: float

signal damaged(amount: float, source: Node, power: int, direction: Vector2i)
signal healed(amount: float)
signal dead()

var alive: bool = true
var current_health: float
var has_i_frames: bool = false

func _ready() -> void:
	current_health = max_health
	if i_frame_timer != null:	
		i_frame_timer.timeout.connect(_on_i_frames_timeout)

func _on_i_frames_timeout() -> void:
	has_i_frames = false

func damage(amount: float, source: Node, power: int, direction: Vector2i) -> void:
	if i_frame_timer == null:
		current_health -= amount
		damaged.emit(amount, source, power, direction)
		if current_health <= 0:
			alive = false
			dead.emit()
	elif !has_i_frames:
		has_i_frames = true
		i_frame_timer.start()
		current_health -= amount
		damaged.emit(amount, source, power, direction)
		if current_health <= 0:
			alive = false
			dead.emit()

func heal(amount: float) -> void:
	current_health += amount
	healed.emit(amount)
