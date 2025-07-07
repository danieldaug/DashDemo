extends AnimatedSprite2D

@export var speed: float = 200.0

# Constants
const DECEL: float = 2.0

func _physics_process(delta):
    position.y += speed * delta
    speed -= DECEL
    if !is_playing():
        queue_free()
