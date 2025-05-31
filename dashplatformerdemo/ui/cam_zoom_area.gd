extends Area2D

@export var transition_speed: float = 5.0
@export var zoom: float = 1.0
@export var collision_shape: CollisionShape2D
@export var water_ui: CanvasLayer

@onready var target_position: Vector2 = collision_shape.global_position
var player_inside: bool = false
var player: Player
var camera: Camera2D
var original_zoom: Vector2
var resetting: bool = false
var current_shader_position: Vector2

func _process(delta):
    if player_inside:
        # Smoothly interpolate camera position and zoom
        camera.global_position = camera.global_position.lerp(target_position, transition_speed * delta)
        camera.zoom = camera.zoom.lerp(Vector2(zoom, zoom), transition_speed * delta)
        current_shader_position = current_shader_position.lerp(target_position, delta * transition_speed)
        water_ui.panel.material.set_shader_parameter("camera_position", current_shader_position)
    else:
        if resetting:
            camera.global_position = camera.global_position.lerp(player.global_position, transition_speed * delta)
            camera.zoom = camera.zoom.lerp(original_zoom, transition_speed * delta)
            water_ui.panel.material.set_shader_parameter("camera_position", player.camera.global_position)
            if camera.global_position == player.global_position:
                resetting = false
                player = null
                camera = null

func _on_body_entered(body):
    if body is Player:
        player = body
        camera = player.camera
        original_zoom = camera.zoom
        player_inside = true
        water_ui.updating = false
        current_shader_position = water_ui.panel.global_position

func _on_body_exited(body):
    if body is Player:
        resetting = true
        player_inside = false
