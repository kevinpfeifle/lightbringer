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

var light_1_active: bool = true
var light_2_active: bool = true
var light_3_active: bool = true
var light_4_active: bool = true
var light_5_active: bool = true

func _ready() -> void:
	health_pool_ap.play("full_health")
	light_1_ap.play("hud_light_1/available")
	light_2_ap.play("hud_light_2/available")
	light_3_ap.play("hud_light_3/available")
	light_4_ap.play("hud_light_4/available")
	light_5_ap.play("hud_light_5/available")

	player.health_component.damaged.connect(_on_player_damaged)
	player.health_component.healed.connect(_on_player_healed)
	player.light_component.consumed.connect(_on_light_consumed)
	player.light_component.depleted.connect(_on_light_depleted)
	player.light_component.resource_reset.connect(_on_light_reset)
	player.light_component.restored.connect(_on_light_restored)
	player.light_component.overflowed.connect(_on_light_overflowed)

func _on_player_damaged(_amount: float, source: Node, _power: int, _direction: Vector2):
	update_health_bar(source)

func _on_player_healed(_amount: float):
	update_health_bar()

func update_health_bar(damage_source: Node2D = null) -> void:
	block_last_light = _block_last_light()

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
	elif player.health_component.current_health == 0:
		if !light_depleted:
			_on_light_depleted()
		health_pool_ap.play("dead")
	
	if damage_source != Player && block_last_light:
		light_1_ap.play("hud_light_1/shadow_restored")
		light_1_ap.queue("hud_light_1/shadow_available")

func _on_light_consumed(_amount: float) -> void:
	var total_light: int = player.light_component.current_resource as int

	# Animate the proper light slot as consumed based on current light.
	if total_light <= 1:
		light_2_ap.play("hud_light_2/consumed")
		light_2_active = false
	elif total_light <= 2:
		light_3_ap.play("hud_light_3/consumed")
		light_3_active = false
	elif total_light <= 3:
		light_4_ap.play("hud_light_4/consumed")
		light_4_active = false
	elif total_light <= 4:
		light_5_ap.play("hud_light_5/consumed")	
		light_5_active = false

func _on_light_depleted() -> void:	
	light_depleted = true
	# Animate all light slots going to shadow to show that player took damage.
	light_1_ap.play("hud_light_1/shadow_consumed")
	light_2_ap.play("hud_light_2/shadow_consumed")
	light_3_ap.play("hud_light_3/shadow_consumed")
	light_4_ap.play("hud_light_4/shadow_consumed")
	light_5_ap.play("hud_light_5/shadow_consumed")

	light_1_active = false
	light_2_active = false
	light_3_active = false
	light_4_active = false
	light_5_active = false

func _on_light_reset() -> void:
	light_depleted = false
	block_last_light = _block_last_light()
	# Animate all light slots returning to show full light. 
	# If player is at 1 health, show slot 1 as shadow to denote it unavailable.
	if block_last_light:
		light_1_ap.queue("hud_light_1/shadow_restored")
	else:
		light_1_ap.queue("hud_light_1/restored")
	light_2_ap.queue("hud_light_2/restored")
	light_3_ap.queue("hud_light_3/restored")
	light_4_ap.queue("hud_light_4/restored")
	light_5_ap.queue("hud_light_5/restored")

	light_1_active = true
	light_2_active = true
	light_3_active = true
	light_4_active = true
	light_5_active = true

	# Animate all light slots as active
	# If player is at 1 health, show slot 1 as shadow to denote it unavailable.
	if block_last_light:
		light_1_ap.queue("hud_light_1/shadow_available")
	else:
		light_1_ap.queue("hud_light_1/available")
	light_2_ap.queue("hud_light_2/available")
	light_3_ap.queue("hud_light_3/available")
	light_4_ap.queue("hud_light_4/available")
	light_5_ap.queue("hud_light_5/available")

func _on_light_restored(_amount_restored: float, residual_amount: float) -> void:
	var overflowed: bool = false
	var total_light: int = player.light_component.current_resource as int
	light_depleted = false

	# Animate each light slot restored and then shown as available.
	if total_light == player.light_component.max_resource && !player.health_component.full_health() && residual_amount > 0:
		# If we have more than 5 light after collecting some, overflow the animation to denote healing.
		overflowed = true
		light_1_ap.play("hud_light_1/overflow")
		light_2_ap.play("hud_light_2/overflow")
		light_3_ap.play("hud_light_3/overflow")
		light_4_ap.play("hud_light_4/overflow")
		light_5_ap.play("hud_light_5/overflow")
	else:
		if total_light > 1 && !light_2_active:
			light_2_ap.queue("hud_light_2/restored")
			light_2_active = true
		if total_light > 2 && !light_3_active:
			light_3_ap.queue("hud_light_3/restored")
			light_3_active = true
		if total_light > 3 && !light_4_active:
			light_4_ap.queue("hud_light_4/restored")
			light_4_active = true
		if total_light > 4 && !light_5_active:
			light_5_ap.queue("hud_light_5/restored")
			light_5_active = true

	# Queue each animation to play the standard available once after its processing is finished.
	if !overflowed:
		if light_2_active:
			light_2_ap.queue("hud_light_2/available")
		if light_3_active:
			light_3_ap.queue("hud_light_3/available")
		if light_4_active:
			light_4_ap.queue("hud_light_4/available")
		if light_5_active:
			light_5_ap.queue("hud_light_5/available")

func _on_light_overflowed(_overflow_amount: float) -> void:
	# If we overflowed, set the amount to the overflow amount.
	var total_light: int = player.light_component.current_resource as int

	light_1_active = false
	light_2_active = false
	light_3_active = false
	light_4_active = false
	light_5_active = false

	# Restore lights to denote the amount present after overflow.
	if total_light > 0:
		light_1_ap.queue("hud_light_1/restored")
		light_1_ap.queue("hud_light_1/available")
		light_1_active = true
	if total_light > 1:
		light_2_ap.queue("hud_light_2/restored")
		light_2_ap.queue("hud_light_2/available")
		light_2_active = true
	if total_light > 2:
		light_3_ap.queue("hud_light_3/restored")
		light_3_ap.queue("hud_light_3/available")
		light_3_active = true
	if total_light > 3:
		light_4_ap.queue("hud_light_4/restored")
		light_4_ap.queue("hud_light_4/available")
		light_4_active = true
	if total_light > 4:
		light_5_ap.queue("hud_light_5/restored")
		light_5_ap.queue("hud_light_5/available")
		light_5_active = true

func _block_last_light() -> bool:
	return player.health_component.current_health == 1
