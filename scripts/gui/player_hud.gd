class_name PlayerHUD
extends Control

@export var player: Player

@export_group("Animation Players")
@export var health_pool_ap: AnimationPlayer
@export var light_1_ap: AnimationPlayer
@export var light_2_ap: AnimationPlayer
@export var light_3_ap: AnimationPlayer
@export var light_4_ap: AnimationPlayer
@export var light_5_ap: AnimationPlayer

var block_last_light: bool = false
var light_depleted: bool = false
var total_light: int

func _ready() -> void:
	health_pool_ap.play("full_health")
	light_1_ap.play("available")
	light_2_ap.play("available")
	light_3_ap.play("available")
	light_4_ap.play("available")
	light_5_ap.play("available")

	total_light = player.light_component.max_resource as int
	player.light_component.consumed.connect(_on_light_consumed)
	player.light_component.depleted.connect(_on_light_depleted)
	player.light_component.resource_reset.connect(_on_light_reset)
	player.light_component.restored.connect(_on_light_restored)

func _process(_delta) -> void:
	# Animate the health pool based on the current health.
	if player.health_component.current_health == 5:
		health_pool_ap.play("full_health")
	elif player.health_component.current_health == 4:
		health_pool_ap.play("4_health")
	elif player.health_component.current_health == 3:
		health_pool_ap.play("3_health")
	elif player.health_component.current_health == 2:
		health_pool_ap.play("2_health")
	elif player.health_component.current_health == 1:
		health_pool_ap.play("1_health")
	else:
		if !light_depleted:
			_on_light_depleted()
		health_pool_ap.play("dead")

func _on_light_consumed(amount: float) -> void:
	total_light -= amount as int

	# Animate the proper light slot as consumed based on current light.
	if total_light <= 1:
		light_2_ap.play("consumed")
	elif total_light <= 2:
		light_3_ap.play("consumed")
	elif total_light <= 3:
		light_4_ap.play("consumed")
	elif total_light <= 4:
		light_5_ap.play("consumed")	

func _on_light_depleted() -> void:	
	light_depleted = true
	# Animate all light slots going to shadow to show that player took damage.
	light_1_ap.play("shadow_consumed")
	light_2_ap.play("shadow_consumed")
	light_3_ap.play("shadow_consumed")
	light_4_ap.play("shadow_consumed")
	light_5_ap.play("shadow_consumed")

func _on_light_reset() -> void:
	light_depleted = false
	block_last_light = _block_last_light()
	# Animate all light slots returning to show full light. 
	# If player is at 1 health, show slot 1 as shadow to denote it unavailable.
	if block_last_light:
		light_1_ap.queue("shadow_restored")
	else:
		light_1_ap.queue("restored")
	light_2_ap.queue("restored")
	light_3_ap.queue("restored")
	light_4_ap.queue("restored")
	light_5_ap.queue("restored")

	# Animate all light slots as active
	# If player is at 1 health, show slot 1 as shadow to denote it unavailable.
	if block_last_light:
		light_1_ap.queue("shadow_available")
	else:
		light_1_ap.queue("available")
	light_2_ap.queue("available")
	light_3_ap.queue("available")
	light_4_ap.queue("available")
	light_5_ap.queue("available")

	total_light = player.light_component.max_resource as int

func _on_light_restored(amount: float) -> void:
	total_light += amount as int
	light_depleted = false
	# Animation each light slot restored and then shown as available.
	# TODO: This will likely need updates once light restored is actually implemented.
	if total_light > 1:
		light_2_ap.play("restored")
		light_2_ap.queue("available")
	if total_light > 2:
		light_3_ap.play("restored")
		light_3_ap.queue("available")
	if total_light > 3:
		light_4_ap.play("restored")
		light_4_ap.queue("available")
	if total_light > 4:
		light_5_ap.play("restored")
		light_5_ap.queue("available")

func _block_last_light() -> bool:
	return player.health_component.current_health == 1
