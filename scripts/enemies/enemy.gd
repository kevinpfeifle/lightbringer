class_name Enemy
extends CharacterBody2D

@export_group("Components")
@export var direction_component: DirectionComponent
@export var health_component: HealthComponent
@export var knockback_component: KnockbackComponent

@export_group("Sprite")
@export var animation_player: AnimationPlayer

func _ready() -> void:
	health_component.damaged.connect(_on_damaged)
	health_component.dead.connect(_on_death)

## Override in child class if omni-directional knockback is not suitable. Hint: It is only good for flying enemies.
func _on_damaged(_amount: float, _source: Node, _power: int, direction: Vector2):
	knockback_component.initialize_knockback(direction)

func _on_death():
	animation_player.play("death")
