extends CharacterBody2D
class_name Player

signal Respawned(data: Vector2)

@export var aim_sprite: Sprite2D
@export var camera: Camera2D
@export var sprite: AnimatedSprite2D
@export var health_component: HealthComponent
@export var tile_detection_component: TileDetectionComponent
@export var state_machine: StateMachine
@export var dash_cooldown: Timer
@export var resaturated_fx: GPUParticles2D
@export var tilemap_detection: TileMapLayer

var controls_disabled: bool = false
var disable_switched: bool = false

var cur_speed: float = 0.0
var dash_aim: Vector2 = Vector2.ZERO
var bouncing: bool = false
@onready var last_spawn: Vector2 = global_position
var tween: Tween
var aim_angle: Vector2

# Camera Shake
var shake_strength: float = 0.0
var shake_fade: float = 10.0
var random_strength: float = 50.0
var cam_shake: bool = false
var cam_locked: bool = false

@onready var camera_origin: Vector2 = camera.offset

# Constants
const ACCEL_X: float = 600.0
const MAX_SPEED_X: float = 500.0
const ACCEL_Y: float = 700.0
const GRAVITY: float = 250.0
const CAM_RESET_SPEED: float = 5.0

const SATURATION_1: Color = Color("e189de")
const SATURATION_2: Color = Color("ffd3ed")
const SATURATION_3: Color = Color("ac41ba")
const SATURATION_4: Color = Color("6b1d8e")
const DESATURATION_1: Color = Color("cfb7cf")
const DESATURATION_2: Color = Color("f5e9f0")
const DESATURATION_3: Color = Color("9e7da2")
const DESATURATION_4: Color = Color("61446f")
const COLOR_PARAMETERS: Array[String] = ["NEWCOLOR1", "NEWCOLOR2", "NEWCOLOR3", "NEWCOLOR4"]

func _ready():
    Global.player = self
    #global_position = Vector2(-100, -15)
    #last_spawn = global_position
    
func disable_enable():
    controls_disabled = !controls_disabled
    disable_switched = true

func _physics_process(delta):
    if controls_disabled:
        if disable_switched:
            disable_switched = false
            state_machine.process_mode = Node.PROCESS_MODE_DISABLED
        velocity.x = 0
        velocity.y += GRAVITY * delta
        move_and_slide()
        if get_slide_collision_count() > 0:
            sprite.play("idle")
        return
    if disable_switched:
        disable_switched = false
        state_machine.process_mode = Node.PROCESS_MODE_INHERIT
    if !bouncing:
        if Input.is_action_pressed("left"):
            if cur_speed > 0: 
                cur_speed = 0
            cur_speed = move_toward(cur_speed, -MAX_SPEED_X, ACCEL_X * delta)
        elif Input.is_action_pressed("right"):
            if cur_speed < 0: 
                cur_speed = 0
            cur_speed = move_toward(cur_speed, MAX_SPEED_X, ACCEL_X * delta)
        else:
            cur_speed = move_toward(cur_speed, 0, ACCEL_X * 5 * delta)
        velocity.x = cur_speed

func _process(delta):
    _shake(delta)
    if cam_shake:
        cam_shake = false
        _apply_cam_shake()
    aim_ui()

func respawn() -> void:
    await Global.ui.fade_out(true)
    await Global.ui.fade_in()
    health_component.health = health_component.max_health
    Global.ui.change_health(health_component.health)
    tile_detection_component.hit = false
    Respawned.emit(global_position)

func aim_ui() -> void:
    var input_vector = Vector2(
            Input.get_action_strength("right") - Input.get_action_strength("left"),
            Input.get_action_strength("down") - Input.get_action_strength("up")
        )

    aim_angle = input_vector.normalized() if input_vector.length() > 0 else Vector2.ZERO
    if aim_angle != Vector2.ZERO:
        aim_sprite.visible = true
        aim_sprite.rotation = aim_angle.angle()
    else:
        aim_sprite.visible = false

func change_saturation_1(color_value: Color) -> void:
    sprite.material.set_shader_parameter(COLOR_PARAMETERS[0], color_value)

func change_saturation_2(color_value: Color) -> void:
    sprite.material.set_shader_parameter(COLOR_PARAMETERS[1], color_value)

func change_saturation_3(color_value: Color) -> void:
    sprite.material.set_shader_parameter(COLOR_PARAMETERS[2], color_value)

func change_saturation_4(color_value: Color) -> void:
    sprite.material.set_shader_parameter(COLOR_PARAMETERS[3], color_value)

func desaturate():
    if tween:
        tween.kill()
    tween = self.create_tween()
    tween.tween_method(change_saturation_1, SATURATION_1, DESATURATION_1, 0.2)
    tween.tween_method(change_saturation_2, SATURATION_2, DESATURATION_2, 0.2)
    tween.tween_method(change_saturation_3, SATURATION_3, DESATURATION_3, 0.2)
    tween.tween_method(change_saturation_4, SATURATION_4, DESATURATION_4, 0.2)

func saturate():
    if tween:
        tween.kill()
    tween = self.create_tween()
    tween.tween_method(change_saturation_1, DESATURATION_1, SATURATION_1, 0.1)
    tween.tween_method(change_saturation_2, DESATURATION_2, SATURATION_2, 0.1)
    tween.tween_method(change_saturation_3, DESATURATION_3, SATURATION_3, 0.1)
    tween.tween_method(change_saturation_4, DESATURATION_4, SATURATION_4, 0.1)
    resaturated_fx.emitting = true

# general shake function
func _shake(delta: float):
    if shake_strength > 0:
        shake_strength = lerpf(shake_strength, 0.0, shake_fade * delta)
        if shake_strength < 0.1:
            shake_strength = 0
        var cam_offset = random_offset()
        camera.offset.x = cam_offset.x + camera_origin.x
        camera.offset.y = cam_offset.y + camera_origin.y
    elif state_machine.current_state != state_machine.states["Dashing"] and camera.offset != camera_origin:
        camera.offset = camera.offset.lerp(camera_origin, CAM_RESET_SPEED * delta)
        if camera.offset.distance_to(camera_origin) < 1:
            camera.offset = camera_origin

func _apply_cam_shake():
    shake_strength = random_strength

func random_offset() -> Vector2:
    return Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
