class_name Player
extends CharacterBody2D


@export var camera: Camera
@export var starting_direction: DirectionComponent.Direction = DirectionComponent.Direction.LEFT

@export_group("Components")
@export var direction_component: DirectionComponent
@export var gravity_component: GravityComponent
@export var health_component: HealthComponent
@export var knockback_component: KnockbackComponent

@export_group("State Machine")
@export var primary_state_machine: StateMachine
@export var secondary_state_machine: StateMachine

@export_group("Sprite")
@export var sprite: Sprite2D
@export var animation_player: AnimationPlayer
@export var player_light: PointLight2D

@export_group("Hurtboxes")
@export var above_hurtbox: Area2D
@export var front_hurtbox: Area2D

@export_group("Timers")
@export var coyote_timer: Timer
@export var hurt_lockout_timer: Timer # Duration the player cannot act after getting hurt.
@export var iframe_timer: Timer # Duration the player gets invulnerability frames after being hurt.
@export var input_buffer_timer: Timer # Duration to buffer inputs like attacking and jumping if they are doing rapdily.

@export_group("Debug")
@export var debug_enabled: bool = false
@export var debug_label: Label

signal speed_changed(running: bool)

# Constants for use in the light related functions that some states use.
const CLOAK_CLOSED_LIGHT_ENERGY: float = 0.8
const CLOAK_CLOSED_LIGHT_DISTANCE: Vector2 = Vector2(20, 20)
const CLOAK_OPEN_LIGHT_ENERGY: float = 1.25
const CLOAK_OPEN_LIGHT_DISTANCE: Vector2 = Vector2(35, 35)
const ATTACK_LIGHT_ENERGY: float = 1.5
const ATTACK_LIGHT_DISTANCE: Vector2 = Vector2(50, 50)
const DEATH_LIGHT_ENERGY: float = 0.5
const DEATH_LIGHT_DISTANCE: Vector2 = Vector2(15, 15)
# Physics Constants.
const JUMP_VELOCITY: float = -1000.0
const WALK_SPEED: float = 400.0
const RUN_SPEED: float = 600.0
# Collision Layer constants.
const ENEMY_COLLISION_LAYER: int = 4
const ONE_WAY_PLATFORM_COLLISION_LAYER: int = 2

var alive: bool = true
var buffered_input: StringName = "" # Inputs can be buffered for 200ms. See BufferedInputTimer.
var collide_one_way: bool = true
var compounding_gravity: bool = true
var is_hurt: bool = false
var speed: float = WALK_SPEED
var running: bool = false

func _ready() -> void:
	iframe_timer.timeout.connect(_on_i_frames_timeout)
	direction_component.direction_changed.connect(_on_direction_changed)
	direction_component.current_direction = starting_direction

func _process(_delta) -> void:
	if debug_enabled:
		debug_label.text = "Current Primary State: %s\nCurrent Secondary State: %s\nVelocity: %s\nBuffered Input: %s\nCurrent Animation: %s\nSpeed: %s" % \
			[primary_state_machine.current_state.state_name, secondary_state_machine.current_state.state_name, 
			velocity, buffered_input, animation_player.current_animation, speed]
	else:
		debug_label.visible = false

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

func _on_direction_changed() -> void:
	if direction_component.current_direction == direction_component.Direction.RIGHT:
		sprite.flip_h = true
		front_hurtbox.scale.x = -1
		above_hurtbox.scale.x = -1
	elif direction_component.current_direction == direction_component.Direction.LEFT:
		sprite.flip_h = false
		front_hurtbox.scale.x = 1
		above_hurtbox.scale.x = 1

func _on_i_frames_timeout() -> void:
	if alive:
		set_collision_mask_value(ENEMY_COLLISION_LAYER, true)

func _on_input_buffer_timer_timeout() -> void:
	buffered_input = "" # Clear the input buffer it isn't consumed in 200ms.

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

func decrease_light() -> void:
	var light_factor: float = clamp(health_component.current_health / health_component.max_health, 0.5, 1)
	player_light.energy = lerp(player_light.energy, CLOAK_CLOSED_LIGHT_ENERGY * light_factor, 0.1)
	player_light.scale = lerp(player_light.scale, CLOAK_CLOSED_LIGHT_DISTANCE * light_factor, 0.1)

func increase_light() -> void:
	var light_factor: float = clamp(health_component.current_health / health_component.max_health, 0.5, 1)
	player_light.energy = lerp(player_light.energy, CLOAK_OPEN_LIGHT_ENERGY * light_factor, 0.1)
	player_light.scale = lerp(player_light.scale, CLOAK_OPEN_LIGHT_DISTANCE * light_factor, 0.1)

func death_light() -> void:
	var light_factor: float = clamp(health_component.current_health / health_component.max_health, 0.5, 1)
	player_light.energy = lerp(player_light.energy, DEATH_LIGHT_ENERGY * light_factor, 0.1)
	player_light.scale = lerp(player_light.scale, DEATH_LIGHT_DISTANCE * light_factor, 0.1)

func attack_light() -> void:
	var light_factor: float = clamp(health_component.current_health / health_component.max_health, 0.5, 1)
	player_light.energy = lerp(player_light.energy, ATTACK_LIGHT_ENERGY * light_factor, 0.1)
	player_light.scale = lerp(player_light.scale, ATTACK_LIGHT_DISTANCE * light_factor, 0.1)