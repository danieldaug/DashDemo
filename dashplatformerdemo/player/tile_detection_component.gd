extends Node
class_name TileDetectionComponent

@export var player: Player
@export var tilemap: TileMapLayer

var hit: bool = false

func _ready():
    # Connect level reset tilemap
    if player.tilemap_detection:
        tilemap = player.tilemap_detection

func is_overlapping_tile() -> bool:
    # Check whether the player overlaps with a reset tile
    var local_pos = tilemap.to_local(player.global_position)
    var cell = tilemap.local_to_map(local_pos)
    if tilemap.get_cell_source_id(cell) != -1:
        return true
    return false

func _physics_process(_delta):
    if not tilemap:
        return
    
    # Respawn player on reset tile collision
    if is_overlapping_tile() and !hit:
        hit = true
        Global.sfx.play("hurt")
        Global.sfx.play("spike_land")
        player.respawn()
