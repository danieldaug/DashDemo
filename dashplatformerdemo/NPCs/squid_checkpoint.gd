extends Node2D
class_name Checkpoint

@export var sprite: AnimatedSprite2D
@export var facing_left: bool = false

var checked: bool = false

func _ready():
    if facing_left:
        sprite.flip_h = true

func _on_area_2d_body_entered(body):
    if !checked and body is Player:
        var player: Player = body
        player.last_spawn = global_position
        checked = true
        sprite.play("hit")
        
