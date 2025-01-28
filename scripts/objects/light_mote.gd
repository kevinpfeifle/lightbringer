class_name LightMote
extends StaticBody2D

@export var animation_player: AnimationPlayer
@export var dissipation_timer: Timer
@export var light_amount: int = 1
@export var light_aura: PointLight2D

@warning_ignore("INTEGER_DIVISION")
func _ready() -> void:
	dissipation_timer.timeout.connect(dissipate)
	animation_player.play("idle")

	# The Point Light of the mote gets more intense the more concentrated the light source.
	light_aura.energy = light_aura.energy + (light_amount / 10)
	light_aura.scale = light_aura.scale * light_amount

	dissipation_timer.start()

func consume() -> void:
	dissipation_timer.stop()
	dissipate()

func dissipate() -> void:
	dissipation_timer.timeout.disconnect(dissipate)
	animation_player.play("dissipate") # This will call queue_free() at the end.