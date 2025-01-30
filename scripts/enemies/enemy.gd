class_name Enemy
extends CharacterBody2D

@export_group("Components")
@export var direction_component: DirectionComponent
@export var health_component: HealthComponent
@export var knockback_component: KnockbackComponent

@export_group("Sprite")
@export var animation_player: AnimationPlayer

var light_mote_scene = preload("res://scenes/objects/light_mote.tscn")

func _ready() -> void:
	health_component.damaged.connect(_on_damaged)
	health_component.dead.connect(_on_death)
	add_to_group("enemies") # Add to the enemies group so the scene knows how many enemies remain.

## Override in child class if omni-directional knockback is not suitable. Hint: It is only good for flying enemies.
func _on_damaged(_amount: float, _source: Node, _power: int, direction: Vector2):
	knockback_component.initialize_knockback(direction)

func _on_death():
	_drop_light_mote()
	animation_player.play("death")

func _drop_light_mote():
	var residual_light: int = (randi() % 3) + 1  # Random amount of light between 1 and 3.
	var light_mote: LightMote = light_mote_scene.instantiate()
	light_mote.light_amount = residual_light
	light_mote.global_position = global_position
	get_tree().current_scene.add_child(light_mote)