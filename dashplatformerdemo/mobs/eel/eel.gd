extends Node2D
class_name Eel

@onready var init_pos: Vector2 = global_position
@export var start_time: float = 0.1
@export var sideways: bool = false
@export var speed: float = 85.0
@export var start_timer: Timer
@export var sprite: AnimatedSprite2D
var moving_forward: bool = true
var started: bool = false

# Constants
const DISTANCE: float = 300.0

func _ready():
    start_timer.start(start_time)
    if sideways:
        rotation_degrees = -90
        sprite.flip_h = true

func _physics_process(delta):
    if started:
        if !sideways:
            if moving_forward:
                if global_position.y < init_pos.y - 1:
                    global_position.y = move_toward(global_position.y, init_pos.y + DISTANCE, speed * delta * 4)
                else:
                    moving_forward = false
            else:
                if global_position.y > init_pos.y - DISTANCE + 1:
                    global_position.y = move_toward(global_position.y, init_pos.y - DISTANCE, speed * delta)
                else:
                    moving_forward = true
                    Global.sfx.play("eel", global_position)
        else:
            if moving_forward:
                if global_position.x < init_pos.x - 1:
                    global_position.x = move_toward(global_position.x, init_pos.x + DISTANCE, speed * delta * 4)
                else:
                    moving_forward = false
            else:
                if global_position.x > init_pos.x - DISTANCE + 1:
                    global_position.x = move_toward(global_position.x, init_pos.x - DISTANCE, speed * delta)
                else:
                    moving_forward = true
                    Global.sfx.play("eel", global_position)

func _on_player_detection_body_entered(body):
    if body is Player:
        body.velocity = Vector2.ZERO
        body.state_machine.on_transition(body.state_machine.current_state, "OffSurface")


func _on_start_timer_timeout():
    started = true
