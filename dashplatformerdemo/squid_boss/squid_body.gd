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
@export var left_hitbox: Area2D
@export var right_hitbox: Area2D
@export var player: Player

@onready var origin: Vector2 = global_position
var rightward: bool = false
var init_position: float = 0.0
var target_position: float = 0.0
var can_blink: bool = false
var blinking: bool = false
var sinking: bool = false
var flinching: bool = false

# Constants
const SINK_SPEED: float = 50.0
const EYE_SPEED: float = 200.0
const BLINK_PAUSE_MIN: float = 3.0
const BLINK_PAUSE_MAX: float = 7.0
const HORIZONTAL_LIMIT: float = 500.0
const MOVEMENT_SPEED: float = 150.0

func _ready():
    enter_idle()
    sway_target()

func _physics_process(delta):
    eye_follow()
    # Swaying
    if target_position:
        global_position.x = move_toward(global_position.x, target_position, MOVEMENT_SPEED * delta)
        if abs(global_position.x - target_position) < 0.1:
            sway_target()

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

func sink(delta):
    global_position.y += SINK_SPEED * delta

func _on_random_blink_timer_timeout():
    can_blink = true

func left_eye_switch():
    damaged_left.visible = true
    left_hitbox.queue_free()

func right_eye_switch():
    damaged_right.visible = true
    right_hitbox.queue_free()

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
