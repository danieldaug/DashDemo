extends CanvasLayer

@export var player: Player
@export var panel: Panel

func _process(_delta):
    var cam_pos = player.camera.position  # Get camera position
    panel.material.set_shader_parameter("camera_position", cam_pos)
