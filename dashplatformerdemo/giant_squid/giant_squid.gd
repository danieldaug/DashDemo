extends Node2D

@export var eye: RigidBody2D
@export var eye_boundary: CollisionPolygon2D
@export var player: Player
@onready var start_position = global_position

var time: float = 0.0

# Constants
const BOB_SPEED: float = 0.75
const MAX_DISPLACEMENT: float = 15.0
const MIN_DISPLACEMENT: float = -15.0
const EYE_SPEED: float = 50.0

func _physics_process(delta: float) -> void:
    time += delta * BOB_SPEED
    global_position.y = start_position.y + sin(time) * MAX_DISPLACEMENT
    move_eye(delta)

func move_eye(delta: float) -> void:
    var direction = (player.global_position - eye.global_position).normalized()
    var velocity = direction * EYE_SPEED
    eye.linear_velocity = velocity
