extends Node2D

@export var sprite: AnimatedSprite2D
var player: Player
var entered: bool = false

func _on_area_2d_body_entered(body):
    if !entered and body is Player:
        player = body
        entered = true
        
        if player.state_machine.current_state is Dashing:
            player.state_machine.current_state.jelly_factor = 0.25
            player.state_machine.current_state.redash = true
            player.saturate()
        # Jelly Animation
        sprite.scale = Vector2(0.85, 0.85)
        var tween = self.create_tween()
        tween.tween_property(sprite, "scale", Vector2(1, 1), 0.3)
        Global.sfx.play("jelly_hit", global_position)

func _on_area_2d_body_exited(body):
    if entered and body is Player:
        if player.state_machine.current_state is Dashing:
            player.state_machine.current_state.jelly_factor = 1.0
            player.state_machine.current_state.redash = false
            player.desaturate()
        
        entered = false
        body = null
