extends Node2D
class_name SquidBody

@export var body: AnimatedSprite2D
@export var eyeballs: AnimatedSprite2D
@export var eyelids: AnimatedSprite2D
@export var damaged_left: AnimatedSprite2D
@export var damaged_right: AnimatedSprite2D
@export var left_eye: RigidBody2D
@export var right_eye: RigidBody2D
@export var random_blink_timer: Timer
@export var switch_timer: Timer
@export var harpoon_blink_timer: Timer
@export var left_hitbox: Area2D
@export var right_hitbox: Area2D
@export var blood: GPUParticles2D
@export var ink: GPUParticles2D
@export var player: Player

@onready var origin: Vector2 = global_position
var rightward: bool = false
var init_position: float = 0.0
var target_position: float = 0.0
var can_blink: bool = false
var blinking: bool = false
var sinking: bool = false
var flinching: bool = false
var switching: bool = false
var rising: bool = false
var on_floor: bool = true
var harpoon_tweens: Array[Tween]
var harpoon_blinking: bool = false

# Constants
const SINK_SPEED: float = 50.0
const EYE_SPEED: float = 200.0
const BLINK_PAUSE_MIN: float = 3.0
const BLINK_PAUSE_MAX: float = 7.0
const HORIZONTAL_LIMIT: float = 500.0
const MOVEMENT_SPEED: float = 150.0
const SWITCH_BOUNDARY: float = 800.0
const SWITCH_SPEED: float = 400.0
const SWITCH_PAUSE_MIN: float = 10.0
const SWITCH_PAUSE_MAX: float = 20.0
const HARPOON_BLINK_PAUSE: float = 6.0
const HARPOON_BLINK_TIME: float = 4.0
const HARPOON_BLINK_FADE: float = 0.4

const SATURATION_1: Color = Color("9eb0b9")
const SATURATION_2: Color = Color("dee3e5")
const SATURATION_3: Color = Color("3b4151")
const SATURATION_4: Color = Color("000000")
const BLINK_1: Color = Color("f5ff2e")
const BLINK_2: Color = Color("fffee6")
const BLINK_3: Color = Color("f5ad1d")
const BLINK_4: Color = Color("b05800")
const COLOR_PARAMETERS: Array[String] = ["NEWCOLOR1", "NEWCOLOR2", "NEWCOLOR3", "NEWCOLOR4"]

func _ready():
    enter_idle()
    sway_target()
    switch_timer.start(randf_range(SWITCH_PAUSE_MIN, SWITCH_PAUSE_MAX))
    harpoon_blink_timer.start(HARPOON_BLINK_PAUSE)
    harpoon_tweens = [null, null, null, null]

func _physics_process(delta):
    eye_follow()
    # Swaying
    if target_position:
        global_position.x = move_toward(global_position.x, target_position, MOVEMENT_SPEED * delta)
        if abs(global_position.x - target_position) < 0.1:
            sway_target()
    if switching:
        switch_position(delta)

func _process(delta):
    if sinking:
        sink(delta)
        return
    if can_blink and eyelids.frame == 7:
        eyelids.play("blink")
        can_blink = false
        blinking = true
    if blinking and !eyelids.is_playing():
        blinking = false
        enter_idle()
    if flinching:
        if !body.is_playing():
            flinching = false
            enter_idle()

func eye_follow():
    if player:
        var left_direction = (player.global_position - left_eye.global_position).normalized()
        var left_velocity = left_direction * EYE_SPEED
        left_eye.linear_velocity = left_velocity
        var right_direction = (player.global_position - right_eye.global_position).normalized()
        var right_velocity = right_direction * EYE_SPEED
        right_eye.linear_velocity = right_velocity

func enter_idle():
    body.frame = 0
    eyeballs.frame = 0
    eyelids.frame = 0
    damaged_left.frame = 0
    damaged_right.frame = 0
    body.play("default")
    eyeballs.play("default")
    eyelids.play("default")
    damaged_left.play("default")
    damaged_right.play("default")
    random_blink_timer.start(randf_range(BLINK_PAUSE_MIN, BLINK_PAUSE_MAX))

func hurt():
    body.frame = 0
    eyeballs.frame = 0
    eyelids.frame = 0
    damaged_left.frame = 0
    damaged_right.frame = 0
    body.play("hurt")
    eyeballs.play("hurt")
    eyelids.play("hurt")
    damaged_left.play("hurt")
    damaged_right.play("hurt")
    flinching = true

func enter_die():
    harpoon_blink_timer.stop()
    harpoon_blinking = false
    switch_timer.stop()
    switching = false
    if rising:
        on_floor = !on_floor
    rising = false
    random_blink_timer.stop()
    body.frame = 0
    eyeballs.frame = 0
    eyelids.frame = 0
    damaged_left.frame = 0
    damaged_right.frame = 0
    body.play("death")
    eyeballs.play("death")
    eyelids.play("death")
    damaged_left.play("death")
    damaged_right.play("death")
    sinking = true
    ink.emitting = true

func sink(delta):
    if on_floor:
        global_position.y += SINK_SPEED * delta
    else:
        global_position.y -= SINK_SPEED * delta

func _on_random_blink_timer_timeout():
    can_blink = true

func left_eye_switch():
    damaged_left.visible = true

func right_eye_switch():
    damaged_right.visible = true

func sway_target():
    init_position = global_position.x
    if init_position < origin.x:
        target_position = randf_range(origin.x, origin.x + HORIZONTAL_LIMIT)
        rightward = true
    elif init_position > origin.x:
        target_position = randf_range(-HORIZONTAL_LIMIT + origin.x, origin.x)
        rightward = false
    else:
        target_position = randf_range(-HORIZONTAL_LIMIT + origin.x, HORIZONTAL_LIMIT + origin.x)
        rightward = target_position > init_position

func switch_position(delta: float):
    if !sinking:
        if on_floor:
            if rising:
                visible = true
                global_position.y += SWITCH_SPEED * delta
                if global_position.y >= origin.y + 150:
                    global_position.y = origin.y + 150
                    rising = false
                    switching = false
                    on_floor = false
            else:
                blood.emitting = false
                global_position.y += SWITCH_SPEED * delta
                if global_position.y >= origin.y + SWITCH_BOUNDARY:
                    rising = true
                    visible = false
                    global_position.y = origin.y - SWITCH_BOUNDARY
                    rotation_degrees = 180
                    Global.sfx.play("boss_move", global_position)
                    left_eye.position = Vector2(-150, 420)
                    right_eye.position = Vector2(150, 420)
                    blood.rotation_degrees = 180
                    blood.emitting = true
        else:
            if rising:
                visible = true
                global_position.y -= SWITCH_SPEED * delta
                if global_position.y <= origin.y:
                    global_position.y = origin.y
                    rising = false
                    switching = false
                    on_floor = true
            else:
                blood.emitting = false
                global_position.y -= SWITCH_SPEED * delta
                if global_position.y <= origin.y - SWITCH_BOUNDARY:
                    rising = true
                    visible = false
                    global_position.y = origin.y + SWITCH_BOUNDARY
                    rotation_degrees = 0
                    Global.sfx.play("boss_move", global_position)
                    left_eye.position = Vector2(-150, 420)
                    right_eye.position = Vector2(150, 420)
                    blood.rotation_degrees = 0
                    blood.emitting = true

func _on_switch_timer_timeout():
    switching = true
    switch_timer.start(randf_range(SWITCH_PAUSE_MIN, SWITCH_PAUSE_MAX))

func change_saturation_1(color_value: Color) -> void:
    body.material.set_shader_parameter(COLOR_PARAMETERS[0], color_value)

func change_saturation_2(color_value: Color) -> void:
    body.material.set_shader_parameter(COLOR_PARAMETERS[1], color_value)

func change_saturation_3(color_value: Color) -> void:
    body.material.set_shader_parameter(COLOR_PARAMETERS[2], color_value)

func change_saturation_4(color_value: Color) -> void:
    body.material.set_shader_parameter(COLOR_PARAMETERS[3], color_value)

func harpoon_unblink():
    for h_tween in harpoon_tweens:
        if h_tween:
            h_tween.kill()
    harpoon_tweens[0] = create_tween()
    harpoon_tweens[0].tween_method(change_saturation_1, BLINK_1, SATURATION_1, HARPOON_BLINK_FADE)
    harpoon_tweens[1] = create_tween()
    harpoon_tweens[1].tween_method(change_saturation_2, BLINK_2, SATURATION_2, HARPOON_BLINK_FADE)
    harpoon_tweens[2] = create_tween()
    harpoon_tweens[2].tween_method(change_saturation_3, BLINK_3, SATURATION_3, HARPOON_BLINK_FADE)
    harpoon_tweens[3] = create_tween()
    harpoon_tweens[3].tween_method(change_saturation_4, BLINK_4, SATURATION_4, HARPOON_BLINK_FADE)
    
    await harpoon_tweens[3].finished
    
    if harpoon_blinking:
        harpoon_blink()
        
func harpoon_blink():
    if harpoon_blinking:
        for h_tween in harpoon_tweens:
            if h_tween:
                h_tween.kill()
        
        harpoon_tweens[0] = create_tween()
        harpoon_tweens[0].tween_method(change_saturation_1, SATURATION_1, BLINK_1, HARPOON_BLINK_FADE)
        harpoon_tweens[1] = create_tween()
        harpoon_tweens[1].tween_method(change_saturation_2, SATURATION_2, BLINK_2, HARPOON_BLINK_FADE)
        harpoon_tweens[2] = create_tween()
        harpoon_tweens[2].tween_method(change_saturation_3, SATURATION_3, BLINK_3, HARPOON_BLINK_FADE)
        harpoon_tweens[3] = create_tween()
        harpoon_tweens[3].tween_method(change_saturation_4, SATURATION_4, BLINK_4, HARPOON_BLINK_FADE)
        
        await harpoon_tweens[3].finished
        
        harpoon_unblink()

func _on_harpoon_blink_timer_timeout():
    if !harpoon_blinking:
        harpoon_blinking = true
        harpoon_blink()
        harpoon_blink_timer.start(HARPOON_BLINK_TIME)
    else:
        harpoon_blinking = false
        harpoon_blink_timer.start(HARPOON_BLINK_PAUSE)
