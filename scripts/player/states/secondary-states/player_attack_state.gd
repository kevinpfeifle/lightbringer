class_name PlayerAttackState
extends State

## Attack is a secondary state. When it finishes it will transition back to ReadyState.

@export var above_hurtbox: Area2D
@export var front_hurtbox: Area2D
@export var below_hurtbox: Area2D
@export var attack_timer: Timer # AttackTimer ensures we leave the state when the animations ends. It is the length of attack.
@export var attack_knockback_timer: Timer # AttackKnockbackTimer lets us add a small, short impulse knockback in the opposite direction of an attack.
@export var attack_reset_timer: Timer # AttackResetTimer marks attack frequency. Once per timer cycle.

var active_hurtbox: Area2D
var attack_direction: String = ""
var can_attack: bool = true
var could_attack: bool = false # Marker to help with teardown. If can_attack, then set could_attack for teardown.
var landed_attack: bool = false # Marker to ensure we can only attack one enemy per swing.

func _ready() -> void:
	state_name = "attack"

func enter(args) -> void:
	super(args)
	if can_attack:
		if Input.is_action_pressed("player_up"):
			attack_direction = "above"
			active_hurtbox = above_hurtbox
		elif !parent.is_on_floor() && Input.is_action_pressed("player_down"):
			attack_direction = "below"
			active_hurtbox = below_hurtbox
		else:
			attack_direction = "forward"
			active_hurtbox = front_hurtbox

		active_hurtbox.body_entered.connect(_on_attack_hurtbox_entered)
		attack_timer.timeout.connect(_on_attack_timer_timeout)
		attack_reset_timer.timeout.connect(_on_attack_reset_timer_timeout)
		can_attack = false
		could_attack = true
		landed_attack = false
		attack_timer.start()
		attack_reset_timer.start()
	else:
		could_attack = false
		transition.emit("ready", [state_name])

func exit(new_state) -> void:
	super(new_state)
	if could_attack:
		active_hurtbox.body_entered.disconnect(_on_attack_hurtbox_entered)
		attack_timer.timeout.disconnect(_on_attack_timer_timeout)
		active_hurtbox = null
		attack_direction = ""

func physics_update(delta: float) -> void:
	super(delta)
	if !attack_timer.is_stopped() && parent.is_hurt:
		attack_timer.stop()
		transition.emit("ready", [state_name])

func _add_attack_knockback() -> void:
	var force_direction_vector: Vector2i = _map_attack_dir_to_opposite_force_dir(attack_direction)
	if force_direction_vector.x != 0:
		parent.knockback_component.handle_knockback(attack_knockback_timer, force_direction_vector.x, 0, 250.0)
	elif force_direction_vector.y == -1:
		# For downward attacks, the "knockback" is actually a "bounce jump" so transition primary state into the jump state.
		parent.primary_state_machine.current_state.transition.emit("jump", [
			parent.primary_state_machine.current_state,
			state_name
		])
	elif force_direction_vector.y == 1:
		parent.knockback_component.handle_knockback(attack_knockback_timer, 0, 1, 250.0)

func _map_attack_dir_to_opposite_force_dir(direction: String) -> Vector2i:
	if attack_direction == "above":
		return Vector2i(0, 1) 
	elif attack_direction == "below":
		return Vector2i(0, -1)
	elif attack_direction == "forward":
		return Vector2i(parent.direction * -1, 0)
	else:
		return Vector2i(0, 0)

## TODO: Consider revising this to get list of all bodies in the area, and attacking the first.
## I am not sure currently by what metric it picks for overlapping bodies. It probably is random?
func _on_attack_hurtbox_entered(body: Node2D) -> void:
	if !landed_attack && body is CharacterBody2D:
		if body.health_component != null:
			if !attack_timer.is_stopped():
				attack_timer.stop()
				landed_attack = true
				body.health_component.damage(1, parent, 0, parent.direction)
				_add_attack_knockback()
				transition.emit("ready", [state_name])

func _on_attack_timer_timeout() -> void:
	transition.emit("ready", [state_name])

func _on_attack_reset_timer_timeout() -> void:
	attack_reset_timer.timeout.disconnect(_on_attack_reset_timer_timeout)
	can_attack = true
