extends Node2D

@export var sprite: AnimatedSprite2D
@export var light: PointLight2D
var player: Player
var entered: bool = false
@onready var max_glow: float = light.energy
var dimming: bool = true

# Constants
const GLOW_VAR: float = 0.75
const BLINK_SPEED: float = 0.5

func _process(delta):
    if dimming:
        light.energy -= BLINK_SPEED * delta
        if light.energy <= max_glow - GLOW_VAR:
            dimming = false
    else:
        light.energy += BLINK_SPEED * delta
        if light.energy >= max_glow:
            dimming = true

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
