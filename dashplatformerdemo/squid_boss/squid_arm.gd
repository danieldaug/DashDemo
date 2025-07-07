extends Node2D
class_name SquidArm

signal fully_reset(arm_id)

@export var arm_sprites: Array[AnimatedSprite2D]
@export var hand_sprite: AnimatedSprite2D
@export var floor_hurtbox: Area2D
@export var roof_hurtbox: Area2D
@export var charge_timer: Timer
@export var is_forward: bool = true
@export var fade_sprite: Sprite2D

var switching: bool = false
var slapping: bool = false
var vertical_slapping: bool = false
var resetting: bool = false
var shaking: bool = false
var sinking: bool = false
var idling: bool = true
var moving_height: bool = false
var temp_stay_height: bool = false
var target_height: float
@onready var cur_station: Vector2 = global_position
@onready var bob_speed: float = randf_range(0.5, 1)
@export var bob_height: float = 10.0
var angle: float = 0.0
var upward_slapping: bool = false
var shake_center: Vector2
var blink_intensifying: bool = false
var blinking: bool = true
var hand_tween: Tween
var blink_intensity = 0.0

# Constants
const SLAP_SPEED: float = 750.0
const RESET_SPEED: float = 600.0
const SHAKE_STRENGTH: float = 7.0
const SINK_SPEED: float = 70.0
const MIN_CHARGE_TIME: float = 0.25
const MAX_CHARGE_TIME: float = 0.75
const MOVE_HEIGHT_SPEED: float = 1000.0
const SETUP_SINK_TIME: float = 1.5
const HAND_BLINK_TIME: float = 0.2

func _ready():
    if !is_forward:
        for arm_sprite in arm_sprites:
            arm_sprite.play("backward")
        hand_sprite.play("backward")
    else:
        for arm_sprite in arm_sprites:
            arm_sprite.play("forward")
        hand_sprite.play("forward")

func _physics_process(delta):
    # Sprite rotation
    if switching and !hand_sprite.is_playing():
        switching = false
        hand_sprite.frame = 0
        for arm_sprite in arm_sprites:
            arm_sprite.frame = 0
        if is_forward:
            for arm_sprite in arm_sprites:
                arm_sprite.play("forward")
            hand_sprite.play("forward")
        else:
            for arm_sprite in arm_sprites:
                arm_sprite.play("backward")
            hand_sprite.play("backward")
    
    # Hand shader
    hand_sprite.material.set_shader_parameter("blink_intensity", blink_intensity)

    if sinking:
        sink(delta)
    
    if moving_height:
        shake_center.y = global_position.y
        global_position.y = move_toward(global_position.y, target_height, MOVE_HEIGHT_SPEED * delta)
        if abs(global_position.y - target_height) < 0.1:
            moving_height = false
            temp_stay_height = true

    # Slap, shake, reset, and stationary states
    if shaking:
        if temp_stay_height:
            temp_stay_height = false
        var offset = Vector2(
                randf_range(-SHAKE_STRENGTH, SHAKE_STRENGTH),
                randf_range(-SHAKE_STRENGTH, SHAKE_STRENGTH)
            )
        global_position = shake_center + offset
    elif temp_stay_height:
        pass
    elif idling:
        blink_intensity = 0.0
        angle = fmod(angle + bob_speed * delta * TAU, TAU)
        var idle_offset = sin(angle) * bob_height
        global_position.y = cur_station.y + idle_offset
        if !hand_sprite.is_playing():
            if is_forward:
                hand_sprite.play("forward")
            else:
                hand_sprite.play("backward")
    elif slapping:
        blink_intensity = 0.0
        if is_forward:
            global_position.y += SLAP_SPEED * delta
        else:
            global_position.y -= SLAP_SPEED * delta
    elif vertical_slapping:
        blink_intensity = 0.0
        if hand_sprite.animation != "slap_forward" and hand_sprite.animation != "slap_backward":
            if is_forward:
                hand_sprite.animation = "slap_forward"
                hand_sprite.frame = 2
            else:
                hand_sprite.animation = "slap_backward"
                hand_sprite.frame = 2
        if upward_slapping:
            global_position.y -= SLAP_SPEED * delta
        else:
            global_position.y += SLAP_SPEED * delta
        if hand_sprite.frame >= 2:
            hand_sprite.stop()
            hand_sprite.frame = 2      
    elif resetting:
        blink_intensity = 0.0
        if !hand_sprite.is_playing():
            if is_forward:
                hand_sprite.play("forward")
            else:
                hand_sprite.play("backward")
        global_position = global_position.move_toward(cur_station, RESET_SPEED * delta)
        if global_position.distance_to(cur_station) < 0.1:
            resetting = false
            idling = true
            fully_reset.emit(self)

func blink_hand():
    if hand_tween:
        hand_tween.kill()

    hand_tween = create_tween()

    if blink_intensifying:
        hand_tween.tween_property(self, "blink_intensity", 0.0, HAND_BLINK_TIME)
    else:
        hand_tween.tween_property(self, "blink_intensity", 1.0, HAND_BLINK_TIME)

    await hand_tween.finished
    
    if blinking:
        blink_intensifying = !blink_intensifying
        blink_hand()


func slap():
    slapping = true
    if is_forward:
        hand_sprite.animation = "slap_forward"
        hand_sprite.frame = 0
        hand_sprite.stop()
        floor_hurtbox.set_deferred("monitoring", true)
        floor_hurtbox.set_deferred("monitorable", true)
    else:
        hand_sprite.animation = "slap_backward"
        hand_sprite.frame = 0
        hand_sprite.stop()
        roof_hurtbox.set_deferred("monitoring", true)
        roof_hurtbox.set_deferred("monitorable", true)

func vertical_slap():
    idling = false
    vertical_slapping = true
    if is_forward:
        hand_sprite.play("slap_forward")
    else:
        hand_sprite.play("slap_backward")
    roof_hurtbox.set_deferred("monitoring", true)
    roof_hurtbox.set_deferred("monitorable", true)
    floor_hurtbox.set_deferred("monitoring", true)
    floor_hurtbox.set_deferred("monitorable", true)

func end_vertical_slap():
    if is_forward:
        hand_sprite.play("unslap_forward")
    else:
        hand_sprite.play("unslap_backward")

func switch_vertical():
    is_forward = !is_forward
    for arm_sprite in arm_sprites:
        arm_sprite.frame = 0
    hand_sprite.frame = 0
    if is_forward:
        for arm_sprite in arm_sprites:
            arm_sprite.play("turn_forward")
        hand_sprite.play("turn_forward")
    else:
        for arm_sprite in arm_sprites:
            arm_sprite.play("turn_backward")
        hand_sprite.play("turn_backward")
    switching = true

func move_to_height(height: float):
    moving_height = true
    idling = false
    target_height = height

func start_shake():
    shake_center = global_position
    idling = false
    shaking = true
    if !sinking:
        blinking = true
        blink_hand()
        charge_timer.start(randf_range(MIN_CHARGE_TIME, MAX_CHARGE_TIME))
    else:
        roof_hurtbox.set_deferred("monitoring", false)
        roof_hurtbox.set_deferred("monitorable", false)
        floor_hurtbox.set_deferred("monitoring", false)
        floor_hurtbox.set_deferred("monitorable", false)

func end_shake():
    shaking = false
    global_position = shake_center
    blinking = false
    blink_intensifying = false
    
func reset():
    vertical_slapping = false
    slapping = false
    resetting = true
    if is_forward:
        floor_hurtbox.set_deferred("monitoring", false)
        floor_hurtbox.set_deferred("monitorable", false)
    else:
        roof_hurtbox.set_deferred("monitoring", false)
        roof_hurtbox.set_deferred("monitorable", false)

func _on_floor_collision_body_entered(body):
    if slapping and body is TileMapLayer:
        if is_forward:
            hand_sprite.play("slap_forward")
        else:
            hand_sprite.play("slap_backward")
        reset()
    elif vertical_slapping and body is TileMapLayer:
        upward_slapping = !upward_slapping
    Global.sfx.play("boss_thump", global_position)

func enter_die():
    blinking = false
    blink_intensifying = false
    blink_intensity = 0.0
    slapping = false
    resetting = false
    shaking = false
    idling = false
    vertical_slapping = false
    temp_stay_height = false
    sinking = true
    reset()
    charge_timer.start(SETUP_SINK_TIME)

func sink(delta):
    global_position.y += SINK_SPEED * delta
    shake_center = global_position

func _on_charge_timer_timeout():
    if sinking:
        start_shake()
    else:
        temp_stay_height = false
        end_shake()
        slap()
