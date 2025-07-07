extends Node

var player: Player
var ui: UI
var entered_scene: bool = false
var sfx: SFXManager
var music: Music

var music_vol: float = 50.0
var sfx_vol: float = 50.0
var master_vol: float = 50.0

# Scene Paths
var main_menu: PackedScene = preload("uid://oy74uwwbjhb2")
var options_menu: PackedScene = preload("uid://dyyos5mhy0gac")
var level_1: PackedScene = preload("uid://bq60dty5bb5ne")
var menus: Array[PackedScene] = [main_menu, options_menu]

var mouse_pos: Vector2

func _process(_delta):
    mouse_pos = get_viewport().get_mouse_position()
    var rect_size = get_viewport().get_visible_rect()
    if mouse_pos.x <= 0 or mouse_pos.y <= 0 or mouse_pos.x >= rect_size.size.x or mouse_pos.y >= rect_size.size.y:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    else:
        Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
