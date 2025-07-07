extends Node2D
class_name Checkpoint

signal checkpoint_hit

@export var sprite: AnimatedSprite2D
@export var facing_left: bool = false
@export var colors: Array[Color] = [Color(), 
Color(), Color(), Color(), Color(), Color(), Color(), Color()]


# Pre boss variables
@export var pre_boss: bool = false
@export var squid_boss: SquidBoss
@export var boss_activator: Node2D
@export var start_door: TileMapLayer
@export var end_door: TileMapLayer
@export var player: Player

var checked: bool = false
var squid_boss_scene = preload("uid://yyqppf1bcjkh")

func _ready():
    if facing_left:
        sprite.flip_h = true
    sprite.material.set_shader_parameter("OLDCOLOR1", Color(0.6, 0.404, 0.878))
    sprite.material.set_shader_parameter("OLDCOLOR2", Color(0.451, 0.29, 0.804))
    sprite.material.set_shader_parameter("OLDCOLOR3", Color(0.275, 0.133, 0.682))
    sprite.material.set_shader_parameter("OLDCOLOR4", Color(0.82, 0.733, 0.922))
    sprite.material.set_shader_parameter("OLDCOLOR5", Color(0.965, 0.576, 0.106))
    sprite.material.set_shader_parameter("OLDCOLOR6", Color(0.851, 0.357, 0.0))
    sprite.material.set_shader_parameter("OLDCOLOR7", Color(0.745, 0.161, 0.0))
    sprite.material.set_shader_parameter("OLDCOLOR8", Color(1.0, 0.808, 0.463))
    for c in colors.size():
        if colors[c]:
            sprite.material.set_shader_parameter("NEWCOLOR" + str(c + 1), colors[c])

func _on_area_2d_body_entered(body):
    if !checked and body is Player:
        var player_ref: Player = body
        player_ref.last_spawn = global_position
        checked = true
        sprite.play("hit")
        checkpoint_hit.emit()
        player_ref.health_component.health = player_ref.health_component.max_health
        Global.ui.change_health(player_ref.health_component.health)

func _on_respawn(_data: Vector2):
    if pre_boss:
        var boss_pos = squid_boss.global_position
        squid_boss.queue_free()
        var squid_boss_instance = squid_boss_scene.instantiate()
        squid_boss_instance.player = player
        squid_boss_instance.global_position = boss_pos
        squid_boss_instance.start_door = start_door
        squid_boss_instance.end_door = end_door
        get_tree().root.add_child(squid_boss_instance)
        boss_activator.squid_boss = squid_boss_instance
        start_door.global_position.y = start_door.init_pos
        squid_boss = squid_boss_instance
