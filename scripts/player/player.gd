class_name Player
extends CharacterBody2D

@export var starting_direction: DirectionComponent.Direction = DirectionComponent.Direction.LEFT

@export_group("Components")
@export var direction_component: DirectionComponent
@export var gravity_component: GravityComponent
@export var health_component: HealthComponent
@export var knockback_component: KnockbackComponent
@export var light_component: ResourceComponent

@export_group("State Machine")
@export var primary_state_machine: StateMachine
@export var secondary_state_machine: StateMachine

@export_group("Sprite")
@export var sprite: Sprite2D
@export var animation_player: AnimationPlayer
@export var animation_tree: AnimationTree
@export var player_light: PointLight2D

@export_group("Areas")
@export var above_hurtbox: Area2D
@export var front_hurtbox: Area2D
@export var interact_box: Area2D

@export_group("Timers")
@export var coyote_timer: Timer
@export var hurt_lockout_timer: Timer # Duration the player cannot act after getting hurt.
@export var iframe_timer: Timer # Duration the player gets invulnerability frames after being hurt.
@export var input_buffer_timer: Timer # Duration to buffer inputs like attacking and jumping if they are doing rapdily.
@export var respawn_timer: Timer
@export var beacon_timer: Timer

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
const ATTACK_LIGHT_DISTANCE: Vector2 = Vector2(125, 125)
const DEATH_LIGHT_ENERGY: float = 0.75
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
var in_beacon: bool = false
var in_light_source: bool = false
var is_hurt: bool = false
var light_accumulated: int = 0
var speed: float = WALK_SPEED
var running: bool = false

func _ready() -> void:
	light_component.depleted.connect(_on_light_depleted)
	light_component.restored.connect(_on_light_restored)
	interact_box.body_entered.connect(_on_interact_box_body_entered)
	iframe_timer.timeout.connect(_on_i_frames_timeout)
	direction_component.direction_changed.connect(_on_direction_changed)
	direction_component.current_direction = starting_direction
	health_component.healed.connect(_on_healed)
	beacon_timer.timeout.connect(_beacon_heal)

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
		
		if collider is Enemy: # || collider is Boss:
			var collision_direction = (global_position - collider.global_position).normalized()
			var damage_direction: int
			if collision_direction.x >= 0:
				damage_direction = 1
			else:
				damage_direction = -1
			health_component.damage(1, collider, 10, Vector2i(damage_direction, -1)) # Player is knocked back horizontally with slightly vertical added.

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
	var light_factor: float = clamp(health_component.current_health / health_component.max_health, 0.6, 1)
	player_light.energy = lerp(player_light.energy, CLOAK_CLOSED_LIGHT_ENERGY * light_factor, 0.1)
	player_light.scale = lerp(player_light.scale, CLOAK_CLOSED_LIGHT_DISTANCE * light_factor, 0.1)

func increase_light() -> void:
	var light_factor: float = clamp(health_component.current_health / health_component.max_health, 0.6, 1)
	player_light.energy = lerp(player_light.energy, CLOAK_OPEN_LIGHT_ENERGY * light_factor, 0.1)
	player_light.scale = lerp(player_light.scale, CLOAK_OPEN_LIGHT_DISTANCE * light_factor, 0.1)

func death_light() -> void:
	var light_factor: float = clamp(health_component.current_health / health_component.max_health, 0.6, 1)
	player_light.energy = lerp(player_light.energy, DEATH_LIGHT_ENERGY * light_factor, 0.1)
	player_light.scale = lerp(player_light.scale, DEATH_LIGHT_DISTANCE * light_factor, 0.1)

func attack_light() -> void:
	player_light.energy = lerp(player_light.energy, ATTACK_LIGHT_ENERGY, 0.1)
	player_light.scale = lerp(player_light.scale, ATTACK_LIGHT_DISTANCE, 0.1)

## These methods are for tracking the player's light for attacks and abilities.
func _on_light_depleted():
	# If we consume all 5 light, Wick takes damage, and we get 5 light back if we have 1 or more health.
	health_component.damage(1, self, 0, Vector2.ZERO)
	light_component.reset()
	if health_component.current_health > 1:
		light_component.unblock_resource()
	else:
		light_component.block_resource()

@warning_ignore("INTEGER_DIVISION")
func _on_light_restored(_amount_restored: float, residual_amount: float):
	# Only worry about healing and overflow if Wick is damaged.
	if !health_component.full_health():
		if residual_amount > 0:
			var heal_total: int = 1
			var remaining_residual: float = residual_amount
			while remaining_residual / light_component.max_resource > 1:
				heal_total += 1
				remaining_residual -= light_component.max_resource
			health_component.heal(heal_total)

		if light_component.full_resource() && residual_amount > 0:
			while residual_amount / 5 > 1:
				residual_amount -= 5
			light_component.overflow(residual_amount)

func _on_interact_box_body_entered(body: Node2D) -> void:
	if body is LightMote || body is Lightbug:
		# If we have full light and health, ignore Light Motes.
		if light_component.full_resource() && health_component.full_health():
			return
		# If we are missing light, or have full light and are missing health (ie missing a layer of light), collect Light Motes.
		elif !light_component.full_resource() || (light_component.full_resource() && !health_component.full_health()):
			# var light_mote: LightMote = body as LightMote
			if !body.consumed:
				light_component.restore(body.light_amount)
				body.consume()
	
func _on_healed(_amount: int) -> void:
	if health_component.current_health > 1:
		light_component.unblock_resource()

func reconnect_deplete_signal() -> void:
	light_component.depleted.disconnect(_on_light_depleted)
	light_component.depleted.connect(_on_light_depleted)

func _beacon_heal() -> void:
	if in_beacon:
		light_component.restore(1)
		beacon_timer.start()
