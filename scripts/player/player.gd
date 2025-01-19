class_name Player
extends CharacterBody2D

@export var animation_player: AnimationPlayer
@export var debug_label: Label
@export var input_buffer_timer: Timer
@export var sprite: Sprite2D
@export var state_machine: StateMachine

const JUMP_VELOCITY: float = -500.0
const JUMP_CLIP_VELOCITY: float = -250.0
const ONE_WAY_PLATFORM_COLLISION_LAYER: int = 2
const SPEED: float = 300.0

var buffered_input: StringName = "" # Inputs can be buffered for 200ms. See BufferedInputTimer.
var collide_one_way: bool = true

func _process(_delta) -> void:
	debug_label.text = "Current State: %s\nVelocity: %s\nBuffered Input: %s\nCurrent Animation: %s" % \
		[state_machine.current_state.state_name, velocity, buffered_input, animation_player.current_animation]

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("player_down"):
		# Ignore collisions with one-way platforms
		collide_one_way = false
		_set_one_way_collision_detection(collide_one_way)
	elif Input.is_action_just_released("player_down"):
		# Re-enable collisions with one-way platforms
		collide_one_way = true
		_set_one_way_collision_detection(collide_one_way)

	move_and_slide()

func _on_input_buffer_timer_timeout() -> void:
	buffered_input = "" # Clear the input buffer it isn't consumed in 200ms.

func set_facing_direction() -> void:
	if velocity.x > 0:
		sprite.scale.x = -1
	elif velocity.x < 0:
		sprite.scale.x = 1

## Updates the collision mask used for one-way platforms so Wick can either fall through them or stand on them.
func _set_one_way_collision_detection(collide: bool) -> void:
	set_collision_mask_value(ONE_WAY_PLATFORM_COLLISION_LAYER, collide)
