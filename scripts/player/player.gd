class_name Player
extends CharacterBody2D

@export var animation_player: AnimationPlayer
@export var debug_label: Label
@export var coyote_timer: Timer
@export var gravity_component: GravityComponent
@export var health_component: HealthComponent
@export var iframe_timer: Timer
@export var input_buffer_timer: Timer
@export var hurt_timer: Timer
@export var sprite: Sprite2D
@export var primary_state_machine: StateMachine

const JUMP_VELOCITY: float = -800.0
const JUMP_CLIP_VELOCITY: float = -250.0
const ONE_WAY_PLATFORM_COLLISION_LAYER: int = 2
const WALK_SPEED: float = 300.0
const RUN_SPEED: float = 500.0

signal speed_changed(running: bool)

var alive: bool = true
var buffered_input: StringName = "" # Inputs can be buffered for 200ms. See BufferedInputTimer.
var collide_one_way: bool = true
var is_hurt: bool = false
var speed: float = WALK_SPEED
var running: bool = false

func _process(_delta) -> void:
	# print(primary_state_machine.current_state.state_name, speed)
	debug_label.text = "Current Movement State: %s\nVelocity: %s\nBuffered Input: %s\nCurrent Animation: %s\nSpeed: %s" % \
		[primary_state_machine.current_state.state_name, velocity, buffered_input, animation_player.current_animation, speed]

func _physics_process(delta: float) -> void:
	var is_falling: bool = primary_state_machine.current_state.state_name == "fall"
	gravity_component.handle_gravity(self, delta, is_falling)
	_set_player_speed()

	if Input.is_action_just_pressed("player_down"):
		# Ignore collisions with one-way platforms
		collide_one_way = false
		_set_one_way_collision_detection(collide_one_way)
	elif Input.is_action_just_released("player_down"):
		# Re-enable collisions with one-way platforms
		collide_one_way = true
		_set_one_way_collision_detection(collide_one_way)

	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		var enemy: Enemy = collider as Enemy

		if enemy:
			var collision_direction = (global_position - enemy.global_position).normalized()
			health_component.damage(1, enemy, 10, collision_direction)

func _on_input_buffer_timer_timeout() -> void:
	buffered_input = "" # Clear the input buffer it isn't consumed in 200ms.

func set_facing_direction(direction: int) -> void:
	if direction > 0:
		sprite.flip_h = true
	elif direction < 0:
		sprite.flip_h = false

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
