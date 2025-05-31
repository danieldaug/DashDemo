extends Node2D
class_name Eel

@onready var init_pos: Vector2 = global_position
var moving_forward: bool = true

# Constants
const SPEED: float = 85.0
const DISTANCE: float = 300.0

func _physics_process(delta):
    if moving_forward:
        if global_position.y < init_pos.y - 1:
            global_position.y = move_toward(global_position.y, init_pos.y + DISTANCE, SPEED * delta * 4)
        else:
            moving_forward = false
    else:
        if global_position.y > init_pos.y - DISTANCE + 1:
            global_position.y = move_toward(global_position.y, init_pos.y - DISTANCE, SPEED * delta)
        else:
            moving_forward = true

func _on_player_detection_body_entered(body):
    if body is Player:
        print("here")
        body.velocity = Vector2.ZERO
        body.state_machine.on_transition(body.state_machine.current_state, "OffSurface")
