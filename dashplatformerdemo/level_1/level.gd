extends Node2D

class_name Level

@export var player: Player
@export var spawn_point: Vector2
@export var canvas_modulate: CanvasModulate

func _ready():
    player.global_position = spawn_point
    player.last_spawn = global_position
