class_name PlayerGlowingState
extends PlayerState

@export var lightbox: Area2D

var state_locked: bool = false

func _ready() -> void:
	state_name = "glowing"

func enter(args: Array) -> void:
	super(args)
	parent.animation_tree.animation_finished.connect(_on_animation_finished)
	lightbox.body_entered.connect(_on_lightbox_body_entered)
	state_locked = true
	if !parent.in_light_source:
		parent.light_component.consume(1)

func exit(new_state: StringName) -> void:
	super(new_state)
	parent.animation_tree.animation_finished.disconnect(_on_animation_finished)
	lightbox.body_entered.disconnect(_on_lightbox_body_entered)

func physics_update(delta) -> void:
	if !state_locked:
		super(delta)
	parent.increase_light()
	parent.velocity.x = 0

func _on_animation_finished(animation_name: StringName):
	if animation_name == "produce_light":
		state_locked = false
		transition.emit("idle", [state_name])

func _on_lightbox_body_entered(body: Node2D):
	if body is Lightbug:
		var lightbug: Lightbug = body as Lightbug
		lightbug.stun()
	elif body is Lantern:
		var lantern: Lantern = body as Lantern
		lantern.light()
