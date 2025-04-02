extends Node2D

@export var sprite: AnimatedSprite2D
var player: Player
var init_speed: float
var entered: bool = false

func _on_area_2d_body_entered(body):
    if !entered and body is Player:
        player = body
        player.dash_component.in_jelly = true
        init_speed = player.velocity.length()  # Store the initial speed magnitude
        
        if !player.dashing:
            player.velocity *= Vector2(0.5, 0.5)
        else:
            player.dash_component.can_dash = true

        player.movement_component.in_jelly = true
        entered = true
        sprite.scale = Vector2(0.85, 0.85)
        var tween = self.create_tween()
        tween.tween_property(sprite, "scale", Vector2(1, 1), 0.3)

func _on_area_2d_body_exited(body):
    if entered and body is Player:
        player.dash_component.in_jelly = false
        player.movement_component.in_jelly = false
        # Restore with original speed magnitude
        if !player.dashing and player.velocity.length() > 0:
            player.velocity = player.velocity.normalized() * max(init_speed, 100.0)

        entered = false
        body = null
