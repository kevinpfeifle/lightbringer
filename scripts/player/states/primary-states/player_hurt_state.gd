class_name PlayerHurtState
extends PlayerState

const DAMPING_SPEED: float = 5.0

var state_locked: bool = false

func _ready() -> void:
	state_name = "hurt"

## Args[1] should be the direction of the source of damage as an Vector2i.
func enter(args: Array) -> void:
	super(args)
	parent.is_hurt = true
	state_locked = true
	parent.hurt_lockout_timer.timeout.connect(_on_hurt_lockout_timer_timeout)
	# Need to cut vertical momentum to zero incase this was mid fall or mid jump, that way the current velocity doesn't impact the knockback.
	parent.velocity.y = 0 
	# For a standard hurt knockback, we always want a small amount of upward knockback, so direction vector's y is always -1.
	parent.knockback_component.initialize_knockback(args[1])
	parent.hurt_lockout_timer.start()

func exit(new_state) -> void:
	super(new_state)
	parent.hurt_lockout_timer.timeout.disconnect(_on_hurt_lockout_timer_timeout)

func physics_update(delta) -> void:
	# Block checking for other states until the knockback timer has completed.
	if !state_locked:
		super(delta)

func _on_hurt_lockout_timer_timeout() -> void:
	parent.is_hurt = false
	state_locked = false
