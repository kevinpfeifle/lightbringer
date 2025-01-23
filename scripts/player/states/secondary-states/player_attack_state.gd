class_name PlayerAttackState
extends State

## Attack is a secondary state. When it finishes it will transition back to ReadyState.

@export var above_hurtbox: Area2D
@export var front_hurtbox: Area2D
@export var below_hurtbox: Area2D
@export var attack_timer: Timer

var active_hurtbox: Area2D
var attack_direction: String = ""
var landed_attack: bool = false

func _ready() -> void:
	state_name = "attack"

func enter(args) -> void:
	super(args)
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
	landed_attack = false
	attack_timer.start()

func exit(new_state) -> void:
	super(new_state)
	active_hurtbox.body_entered.disconnect(_on_attack_hurtbox_entered)
	attack_timer.timeout.disconnect(_on_attack_timer_timeout)
	active_hurtbox = null
	attack_direction = ""

func _on_attack_hurtbox_entered(body: Node2D) -> void:
	if !landed_attack && body is CharacterBody2D:
		if body.health_component != null:
			if !attack_timer.is_stopped():
				attack_timer.stop()
				landed_attack = true
				body.health_component.damage(1, parent, 0, Vector2(parent.direction, 0))
				transition.emit("ready", [state_name])


func _on_attack_timer_timeout() -> void:
	transition.emit("ready", [state_name])
