extends Node2D

@export var spiraling: bool = false
@export var sprite: AnimatedSprite2D
@export var direction_point: Marker2D
@export var speed: float = 10
@export var bounce_strength: float = 600.0

# Straight
@export var direction: Vector2 = Vector2.UP

# Curve
@export var expansion_rate: float = 5.0
@export var angle: float = 0.0  # Current angle in radians
var radius: float = 0.0  # Current radius
@onready var init_pos: Vector2 = global_position

func _physics_process(delta: float):
    if !sprite.is_playing():
        queue_free()
    
    if spiraling:
        angle += -speed * delta
        radius += expansion_rate * delta
        var x = radius * cos(angle)
        var y = radius * sin(angle)
        global_position = init_pos + Vector2(x, y)
    else:
        global_position += direction * speed * delta

func _on_area_2d_body_entered(body):
    if body is PlayerBubbleCollision:
        var player = body.player as Player
        if player.state_machine.current_state is Dashing:
            player.state_machine.current_state.dash_particles.emitting = false
            player.state_machine.current_state.dash_dir = (player.global_position - direction_point.global_position).normalized()
        elif player.state_machine.current_state is OffSurface:
            player.state_machine.current_state.bouncing = true
            player.bouncing = true
            var dir = (player.global_position - direction_point.global_position).normalized()
            player.velocity = dir * bounce_strength
    sprite.play("pop")
    speed = 0
    expansion_rate = 0
