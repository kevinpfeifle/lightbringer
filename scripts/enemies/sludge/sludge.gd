class_name Sludge
extends Enemy

@export var hitbox: CollisionObject2D
@export var gravity_component: GravityComponent
@export var movement_component: MovementComponent
@export var starting_direction: DirectionComponent.Direction = DirectionComponent.Direction.LEFT
@export var speed: float = 200.0
@export var sprite: Sprite2D
@export var state_machine: StateMachine

func _ready() -> void:
	super()
	direction_component.direction_changed.connect(_on_direction_changed)
	direction_component.current_direction = starting_direction

func _physics_process(delta: float) -> void:
	movement_component.handle_movement() # Set inital desired movement before outside outsides.
	gravity_component.handle_gravity(self, delta, true, false) # Keep enemies simple, only standard gravity.
	if health_component.alive:
		knockback_component.handle_knockback(self) # Skip knockback if dying, looks better in the animation.
	move_and_slide()
	knockback_component.handle_knockback_decay()

func _on_direction_changed() -> void:
	if direction_component.current_direction == direction_component.Direction.RIGHT:
		sprite.flip_h = true
	elif direction_component.current_direction == direction_component.Direction.LEFT:
		sprite.flip_h = false

## Implement in the child class.
func _on_damaged(_amount: float, _source: Node, _power: int, direction: Vector2):
	var clamped_direction: Vector2i
	if direction.x >= 0:
		clamped_direction.x = 1
	else:
		clamped_direction.x = -1
	clamped_direction.y = 0 # Sludge doesn't have vertical knockback.
	knockback_component.initialize_knockback(clamped_direction)

func _on_death():
	if WorldGlobals.defeated_enemies.get(WorldGlobals.current_room):
		WorldGlobals.defeated_enemies[WorldGlobals.current_room].append(enemy_id)
	else:
		WorldGlobals.defeated_enemies[WorldGlobals.current_room] = [enemy_id]
	_drop_light_mote()
	state_machine.current_state.transition.emit("death", [state_machine.current_state])
