class_name LightHarvesterAttackState
extends State

var active_hurtbox: Area2D
var can_attack: bool = true

func _ready() -> void:
	state_name = "attack"

func enter(args: Array):
	super(args)
	if can_attack:
		parent.velocity = Vector2.ZERO
		if parent.attack_direction == "above":
			active_hurtbox = parent.above_hurtbox
		elif parent.attack_direction == "front":
			active_hurtbox = parent.front_hurtbox
		active_hurtbox.body_entered.connect(_on_attack_hurtbox_entered)
		parent.attack_timer.timeout.connect(_on_attack_timer_timeout)
		parent.attack_reset_timer.timeout.connect(_on_attack_reset_timer_timeout)
		can_attack = false
		parent.attack_timer.start()
		parent.attack_reset_timer.start()
	else:
		transition.emit("chase", [state_name])

func _on_attack_hurtbox_entered(body: Node2D):
	if body is Player:
		if !parent.attack_timer.is_stopped():
			parent.attack_timer.stop()
			body.health_component.damage(1, parent, 0, Vector2(parent.direction_component.get_direction_as_int(), -1))
			transition.emit("chase", [state_name])

func _on_attack_timer_timeout() -> void:
	transition.emit("chase", [state_name])

func _on_attack_reset_timer_timeout() -> void:
	parent.attack_reset_timer.timeout.disconnect(_on_attack_reset_timer_timeout)
	can_attack = true
