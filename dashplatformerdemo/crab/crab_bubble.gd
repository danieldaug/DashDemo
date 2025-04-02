extends Node2D

@export var spiraling: bool = false
@export var sprite: AnimatedSprite2D
@export var speed: float = 10

# Straight
@export var direction: Vector2 = Vector2.UP

# Curve
@export var expansion_rate: float = 5.0
var angle: float = 0.0  # Current angle in radians
var radius: float = 0.0  # Current radius

# Constants

func _physics_process(delta):
    if !sprite.is_playing():
        queue_free()
    
    if spiraling:
        angle += speed * delta
        radius += expansion_rate * delta
        var x = radius * cos(angle)
        var y = radius * sin(angle)
        global_position = Vector2(x, y)
    else:
        global_position += direction * speed * delta

func _on_area_2d_body_entered(body):
    if body is Player:
        body.health_component.damage(1)
    sprite.play("pop")
    speed = 0
    expansion_rate = 0
