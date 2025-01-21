class_name Player
extends CharacterBody2D

@export var animation_player: AnimationPlayer
@export var debug_label: Label
@export var coyote_timer: Timer
@export var health_component: HealthComponent
@export var iframe_timer: Timer
@export var input_buffer_timer: Timer
@export var knockback_timer: Timer
@export var sprite: Sprite2D
@export var movement_state_machine: StateMachine

const DAMPING_SPEED: float = 5.0
const JUMP_VELOCITY: float = -800.0
const JUMP_CLIP_VELOCITY: float = -250.0
const ONE_WAY_PLATFORM_COLLISION_LAYER: int = 2
const WALK_SPEED: float = 300.0
const RUN_SPEED: float = 500.0

signal speed_changed(running: bool)

var buffered_input: StringName = "" # Inputs can be buffered for 200ms. See BufferedInputTimer.
var collide_one_way: bool = true
var is_knocked_back: bool = false
var speed: float = WALK_SPEED
var running: bool = false

func _ready() -> void:
	health_component.damaged.connect(_on_player_damaged)

func _process(_delta) -> void:
	debug_label.text = "Current Movement State: %s\nVelocity: %s\nBuffered Input: %s\nCurrent Animation: %s" % \
		[movement_state_machine.current_state.state_name, velocity, buffered_input, animation_player.current_animation]

func _physics_process(delta: float) -> void:
	if !is_knocked_back:
		_set_player_speed()

		if Input.is_action_just_pressed("player_down"):
			# Ignore collisions with one-way platforms
			collide_one_way = false
			_set_one_way_collision_detection(collide_one_way)
		elif Input.is_action_just_released("player_down"):
			# Re-enable collisions with one-way platforms
			collide_one_way = true
			_set_one_way_collision_detection(collide_one_way)
	else:
		velocity.x = lerp(velocity.x, 0.0, DAMPING_SPEED * delta)
		velocity.y = lerp(velocity.y, 0.0, DAMPING_SPEED * delta)
	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)

		var collider = collision.get_collider()
		var enemy: Enemy = collider as Enemy

		if enemy:
			var collision_direction = (global_position - enemy.global_position).normalized()
			print(collision_direction)
			health_component.damage(1, enemy, 10, collision_direction)
			# _apply_knockback(collision_direction)

func _on_player_damaged(_amount: int, _source: Node, _power: int, direction: Vector2) -> void:
	is_knocked_back = true
	knockback_timer.start()
	var knockback_strength = 1500.0  # Adjust as needed
	# direction.y = clamp(direction.y, -0.5, 0.5)
	# direction = direction.normalized()
	velocity.x += direction.x * knockback_strength
	velocity.y -= 300

func _on_input_buffer_timer_timeout() -> void:
	buffered_input = "" # Clear the input buffer it isn't consumed in 200ms.

func set_facing_direction() -> void:
	if velocity.x > 0:
		sprite.flip_h = true
	elif velocity.x < 0:
		sprite.flip_h = false

## Updates the collision mask used for one-way platforms so Wick can either fall through them or stand on them.
func _set_one_way_collision_detection(collide: bool) -> void:
	set_collision_mask_value(ONE_WAY_PLATFORM_COLLISION_LAYER, collide)

func _set_player_speed() -> void:
	if Input.is_action_just_pressed("player_run"):
		speed = RUN_SPEED
		running = true
		speed_changed.emit(running)
	elif Input.is_action_just_released("player_run"):
		speed = WALK_SPEED
		running = false
		speed_changed.emit(running)

func _on_knockback_timer_timeout() -> void:
	is_knocked_back = false
