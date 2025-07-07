extends Node2D
class_name SquidGuide

@export var sprite: AnimatedSprite2D
@export var label: Label
@export var text: String
@export var colors: Array[Color] = [Color(), 
Color(), Color(), Color(), Color(), Color(), Color(), Color()]
@export var facing_left: bool = false
var tween: Tween

# Checkpoint vars
@export var is_checkpoint: bool = false
var checked: bool = false

func _ready():
    if text:
        label.text = text
    if facing_left:
        sprite.flip_h = true
    sprite.material.set_shader_parameter("OLDCOLOR1", Color(0.882, 0.537, 0.871))
    sprite.material.set_shader_parameter("OLDCOLOR2", Color(0.675, 0.255, 0.729))
    sprite.material.set_shader_parameter("OLDCOLOR3", Color(0.42, 0.114, 0.557))
    sprite.material.set_shader_parameter("OLDCOLOR4", Color(1.0, 0.827, 0.929))
    sprite.material.set_shader_parameter("OLDCOLOR5", Color(0.867, 0.769, 0.227))
    sprite.material.set_shader_parameter("OLDCOLOR6", Color(0.663, 0.49, 0.051))
    sprite.material.set_shader_parameter("OLDCOLOR7", Color(0.522, 0.294, 0.024))
    sprite.material.set_shader_parameter("OLDCOLOR8", Color(0.953, 1.0, 0.38))
    for c in colors.size():
        if colors[c]:
            sprite.material.set_shader_parameter("NEWCOLOR" + str(c + 1), colors[c])

func _on_area_2d_body_entered(body):
    if body is Player:
        if tween:
            tween.kill()
        tween = create_tween()
        tween.tween_property(label, "modulate:a", 1.0, 0.5)
    if is_checkpoint and !checked and body is Player:
        var player_ref: Player = body
        player_ref.last_spawn = global_position
        checked = true
        player_ref.health_component.health = player_ref.health_component.max_health
        Global.ui.change_health(player_ref.health_component.health)

func _on_area_2d_body_exited(body):
    if body is Player:
        if tween:
            tween.kill()
        tween = create_tween()
        tween.tween_property(label, "modulate:a", 0.0, 0.5)
