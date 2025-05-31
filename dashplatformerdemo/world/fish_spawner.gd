extends Area2D

@export var timer: Timer
@export var collision_shape: CollisionShape2D

var fish: PackedScene = preload("uid://bm2kqi020jp4u")

# Constants
const MAX_SPAWN_RATE: float = 5.0
const MIN_SPAWN_RATE: float = 10.0

func _on_timer_timeout():
    for i in range(3):
        var fish_instance = fish.instantiate()
        var bounds: Shape2D = collision_shape.shape
        fish_instance.global_position = Vector2(
            randf_range(collision_shape.global_position.x - bounds.size.x / 4, 
            collision_shape.global_position.x + bounds.size.x / 4),
            randf_range(collision_shape.global_position.y - bounds.size.y / 2, 
            collision_shape.global_position.y + bounds.size.y / 2)
            )
        fish_instance.facing_left = global_position > collision_shape.global_position
        add_child(fish_instance)
    timer.start(randf_range(MAX_SPAWN_RATE, MIN_SPAWN_RATE))
