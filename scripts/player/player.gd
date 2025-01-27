class_name Player
extends CharacterBody2D

@export var animation_player: AnimationPlayer
@export var above_hurtbox: Area2D
@export var camera: Camera
@export var coyote_timer: Timer
@export var debug_label: Label
@export var starting_direction: Direction = Direction.RIGHT # -1 or 1 to represent left or right respectively.
@export var front_hurtbox: Area2D
@export var gravity_component: GravityComponent
@export var health_component: HealthComponent
@export var hurt_lockout_timer: Timer # Duration the player cannot act after getting hurt.
@export var iframe_timer: Timer # Duration the player gets invulnerability frames after being hurt.
@export var input_buffer_timer: Timer # Duration to buffer inputs like attacking and jumping if they are doing rapdily.
@export var knockback_component: KnockbackComponent
@export var primary_state_machine: StateMachine
@export var secondary_state_machine: StateMachine
@export var sprite: Sprite2D

signal speed_changed(running: bool)

enum Direction { LEFT, RIGHT }

const ENEMY_COLLISION_LAYER: int = 4
const JUMP_VELOCITY: float = -1000.0
const ONE_WAY_PLATFORM_COLLISION_LAYER: int = 2
const WALK_SPEED: float = 400.0
const RUN_SPEED: float = 600.0

var active_knockback_timer: Timer
var alive: bool = true
var buffered_input: StringName = "" # Inputs can be buffered for 200ms. See BufferedInputTimer.
var collide_one_way: bool = true
var compounding_gravity: bool = true
var direction: int = 0
var is_hurt: bool = false
var speed: float = WALK_SPEED
var running: bool = false

func _ready() -> void:
	iframe_timer.timeout.connect(_on_i_frames_timeout)
	if starting_direction == Direction.LEFT:
		set_facing_direction(-1)
	elif starting_direction == Direction.RIGHT:
		set_facing_direction(1)

func _process(_delta) -> void:
	# print(primary_state_machine.current_state.state_name, speed)
	debug_label.text = "Current Primary State: %s\nCurrent Secondary State: %s\nVelocity: %s\nBuffered Input: %s\nCurrent Animation: %s\nSpeed: %s" % \
		[primary_state_machine.current_state.state_name, secondary_state_machine.current_state.state_name, 
		velocity, buffered_input, animation_player.current_animation, speed]

func _physics_process(delta: float) -> void:
	var is_falling = primary_state_machine.current_state.state_name == "fall"
	var is_jumping = primary_state_machine.current_state.state_name == "jump"
	gravity_component.handle_gravity(self, delta, is_falling, is_jumping)

	_set_player_speed()

	if Input.is_action_just_pressed("player_down"):
		# Ignore collisions with one-way platforms
		collide_one_way = false
		_set_one_way_collision_detection(collide_one_way)
	elif Input.is_action_just_released("player_down"):
		# Re-enable collisions with one-way platforms
		collide_one_way = true
		_set_one_way_collision_detection(collide_one_way)

	knockback_component.handle_knockback(self)
	move_and_slide()
	knockback_component.handle_knockback_decay()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		var enemy: Enemy = collider as Enemy

		if enemy:
			var collision_direction = (global_position - enemy.global_position).normalized()
			var damage_direction: int
			if collision_direction.x >= 0:
				damage_direction = 1
			else:
				damage_direction = -1
			health_component.damage(1, enemy, 10, Vector2i(damage_direction, -1)) # Player is knocked back horizontally with slightly vertical added.

func _on_i_frames_timeout() -> void:
	if alive:
		set_collision_mask_value(ENEMY_COLLISION_LAYER, true)

func _on_input_buffer_timer_timeout() -> void:
	buffered_input = "" # Clear the input buffer it isn't consumed in 200ms.

func _on_knockback_started(timer) -> void:
	active_knockback_timer = timer

func set_facing_direction(new_direction: int) -> void:
	direction = new_direction
	if new_direction > 0:
		sprite.flip_h = true
		front_hurtbox.scale.x = -1
		above_hurtbox.scale.x = -1
	elif new_direction < 0:
		sprite.flip_h = false
		front_hurtbox.scale.x = 1
		above_hurtbox.scale.x = 1

func _set_player_speed() -> void:
	if Input.is_action_just_pressed("player_run"):
		speed = RUN_SPEED
		running = true
		speed_changed.emit(running)
	elif Input.is_action_just_released("player_run"):
		speed = WALK_SPEED
		running = false
		speed_changed.emit(running)

## Updates the collision mask used for one-way platforms so Wick can either fall through them or stand on them.
func _set_one_way_collision_detection(collide: bool) -> void:
	set_collision_mask_value(ONE_WAY_PLATFORM_COLLISION_LAYER, collide)