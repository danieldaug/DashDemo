extends Area2D

@export var transition_speed: float = 5.0
@export var zoom: float = 1.0
@export var lock_cam: bool = true
@export var collision_shape: CollisionShape2D
@export var water_ui: CanvasLayer

@onready var target_position: Vector2 = collision_shape.global_position
var player_inside: bool = false
var player_exited: bool = false
var lock_zoom: bool = false
var player: Player
var camera: Camera2D
var original_zoom: Vector2
var resetting: bool = false
var current_shader_position: Vector2

func _process(delta):
    if player_inside:
        # Smoothly interpolate camera position and zoom
        if lock_cam:
            camera.global_position = camera.global_position.lerp(target_position, transition_speed * delta)
        if lock_zoom:
            camera.zoom = Vector2(zoom, zoom)
        if lock_cam:
            current_shader_position = current_shader_position.lerp(target_position, delta * transition_speed)
            water_ui.panel.material.set_shader_parameter("camera_position", current_shader_position)
    elif player_exited:
        if resetting:
            if lock_cam:
                camera.global_position = camera.global_position.lerp(player.global_position, transition_speed * delta)
                camera.zoom = camera.zoom.lerp(original_zoom, transition_speed * delta)
                water_ui.panel.material.set_shader_parameter("camera_position", player.camera.global_position)
                if camera.global_position.distance_to(player.global_position) < 1:
                    camera.global_position = player.global_position
                    resetting = false
                    player = null
                    camera = null
                    player_exited = false
                    print("here")
            else:
                camera.global_position = camera.global_position.lerp(player.global_position, transition_speed * delta)
                camera.zoom = camera.zoom.lerp(original_zoom, transition_speed * delta)
                water_ui.panel.material.set_shader_parameter("camera_position", player.camera.global_position)
                if camera.zoom.distance_to(original_zoom) < 1:
                    camera.zoom = original_zoom
                    resetting = false
                    player = null
                    camera = null
                    player_exited = false

func _on_body_entered(body):
    if body is Player:
        print("entered")
        player = body
        camera = player.camera
        original_zoom = camera.zoom
        player_inside = true
        water_ui.updating = false
        current_shader_position = water_ui.panel.global_position
        if lock_cam:
            player.cam_locked = true
            camera.position_smoothing_enabled = false
        var tween = create_tween()
        tween.tween_property(camera, "zoom", Vector2(zoom, zoom), 1.0)
        await tween.finished
        lock_zoom = true

func _on_body_exited(body):
    if body is Player:
        if !self.get_overlapping_bodies().has(body):
            print("exited")
            player_exited = true
            resetting = true
            player_inside = false
            lock_zoom = false
            water_ui.updating = true
            if lock_cam:
                camera.position_smoothing_enabled = true
                player.cam_locked = false
