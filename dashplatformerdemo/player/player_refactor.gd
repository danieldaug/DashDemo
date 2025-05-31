extends CharacterBody2D
class_name Player

@export var camera: Camera2D
@export var sprite: AnimatedSprite2D
@export var health_component: HealthComponent
@export var state_machine: StateMachine
@export var dash_cooldown: Timer
@export var resaturated_fx: GPUParticles2D

var cur_speed: float = 0.0
var dash_aim: Vector2 = Vector2.ZERO
var bouncing: bool = false
@onready var last_spawn: Vector2 = global_position
var tween: Tween

# Camera Shake
var shake_strength: float = 0.0
var shake_fade: float = 10.0
var random_strength: float = 50.0
var cam_shake: bool = false

# Constants
const ACCEL_X: float = 600.0
const MAX_SPEED_X: float = 500.0
const ACCEL_Y: float = 700.0

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

func _physics_process(delta):
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

func respawn() -> void:
    await Global.ui.fade_out()
    await Global.ui.fade_in()
    health_component.health = health_component.max_health
    Global.ui.change_health(health_component.health)

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
        var cam_offset = random_offset()
        camera.offset.x = cam_offset.x
        camera.offset.y = cam_offset.y - 25.0
    else:
        camera.offset.x = 0
        camera.offset.y = -25

func _apply_cam_shake():
    shake_strength = random_strength

func random_offset() -> Vector2:
    return Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
