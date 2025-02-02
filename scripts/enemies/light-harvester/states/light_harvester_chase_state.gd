class_name LightHarvesterChaseState
extends State

var nav_ready: bool = false
var target_position: Vector2

func _ready() -> void:
	state_name = "chase"

# args[1] is a reference to the body being chased, the Player.
func enter(args: Array) -> void:
	super(args)
	GlobalPlayer.player.health_component.damaged.connect(_on_hit_player)
	NavigationServer2D.map_changed.connect(_on_map_ready)
	if nav_ready:
		parent.nav_agent.target_position = target_position

func exit(new_state: StringName) -> void:
	super(new_state)
	GlobalPlayer.player.health_component.damaged.disconnect(_on_hit_player)
	NavigationServer2D.map_changed.disconnect(_on_map_ready)

func physics_update(delta) -> void:
	super(delta)
	if nav_ready:
		target_position = GlobalPlayer.player.global_position
		parent.nav_agent.target_position = target_position
		if parent.global_position.distance_to(target_position) > 25 && !parent.nav_agent.is_navigation_finished():
			var speed = parent.speed
			var current_location = parent.global_position
			var next_location = parent.nav_agent.get_next_path_position()
			parent.velocity = parent.velocity.lerp((next_location - current_location).normalized() * speed, 0.1)
			parent.velocity.y = 0
			parent.direction_component.set_direction_from_int(parent.velocity.x)

func _on_map_ready(_map: RID) -> void:
	nav_ready = true

func _on_hit_player(_amount, _source, _power, _direction) -> void:
	transition.emit("idle", [state_name])
