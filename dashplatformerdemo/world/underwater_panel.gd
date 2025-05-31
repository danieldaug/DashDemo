extends CanvasLayer

@export var player: Player
@export var panel: Panel
var updating: bool = true

func _process(_delta):
    if updating:
        # Get actual viewport camera position
        var top_left = player.camera.get_screen_center_position() - (get_viewport().get_visible_rect().size * 0.5) * player.camera.zoom
        panel.material.set_shader_parameter("camera_position", top_left)
