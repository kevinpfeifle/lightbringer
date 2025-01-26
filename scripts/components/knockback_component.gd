class_name KnockbackComponent
extends Node

@export var body: CharacterBody2D
@export var default_damping_speed: float = 5.0
@export var default_x_impulse: float = 1250.0
@export var default_y_impulse: float = 350

signal knockback_started(knockback_timer: Timer)
signal knockback_finished()

## horz_direction represents left or right, -1 is left, 1 is right, 0 is none.
## vert_direction represents up or down, -1 is up, 1 is down, 0 is none.
func handle_knockback(knockback_timer: Timer, direction: Vector2i, x_impulse: float = 0.0, y_impulse: float = 0.0) -> void:
	var x_strength = x_impulse if x_impulse != 0.0 else default_x_impulse
	var y_strength = y_impulse if y_impulse != 0.0 else default_y_impulse
	knockback_timer.timeout.connect(_on_knockback_timer_timeout.bind(knockback_timer))
	knockback_timer.start()
	knockback_started.emit(knockback_timer)
	if direction.x != 0:
		body.velocity.x = x_strength * direction.x
	if direction.y != 0:
		body.velocity.y = y_strength * direction.y

func handle_knockback_decay(delta: float, damping_speed: float = 0.0):
	var decay_rate = (damping_speed if damping_speed != 0.0 else default_damping_speed) * delta
	body.velocity.x = lerp(body.velocity.x, 0.0, decay_rate)
	if !body.gravity_component:
		body.velocity.y = lerp(body.velocity.y, 0.0, decay_rate)

func _on_knockback_timer_timeout(knockback_timer: Timer) -> void:
	knockback_timer.timeout.disconnect(_on_knockback_timer_timeout)
	body.velocity = Vector2(0, 0)
	knockback_finished.emit()
