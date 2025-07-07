extends Node2D

@export var sprite: AnimatedSprite2D
var opening: bool = false

func _process(_delta):
    if opening and !sprite.is_playing():
        opening = false
        sprite.play("opened")
        Global.sfx.play("coins", global_position)

func _on_area_2d_body_entered(body):
    if body is Player:
        sprite.play("open")
        Global.sfx.play("chest", global_position)
        opening = true
        var player = body as Player
        player.state_machine.on_transition(player.state_machine.states["Dashing"], "OnSurface")
        player.disable_enable()
        Global.ui.complete_text_container.appear()
        Global.ui.return_container.appear()
        Global.sfx.play("level_complete")
