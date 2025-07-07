extends Node2D

var player_contact: bool = false
var player: Player

func _on_area_2d_body_entered(body):
    if body is Player:
        player = body
        player_contact = true

func _on_area_2d_body_exited(body):
    if body is Player:
        player_contact = false

func _process(_delta):
    if player_contact:
        player.health_component.damage(1)
