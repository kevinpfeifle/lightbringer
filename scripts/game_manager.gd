class_name GameManager
extends Node2D

@export var starting_room: PackedScene  # Set this in the editor

func _ready():
    # If player doesn't exist, create it
    if GlobalPlayer.player == null:
        GlobalPlayer.player = GlobalPlayer.player_scene.instantiate()
    
    # Load the first room
    var room_instance = starting_room.instantiate()
    add_child(room_instance)