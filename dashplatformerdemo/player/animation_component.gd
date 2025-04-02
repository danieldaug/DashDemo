extends Node
class_name AnimationComponent

@export var player: Player
@export var sprite: AnimatedSprite2D
@export var movement_component: MovementComponent
@export var bubble_particles: GPUParticles2D

var on_surface: bool = true
var jump_start: bool = false

# Constants
const ROT_RESET_SPEED: float = 20.0

func _physics_process(delta):
    # Sprite Animations
    if player.dashing:
        sprite.play("dash")
    elif player.velocity.y > 0:
        if movement_component.on_wall:
            sprite.play("walk")
        else:
            sprite.play("fall")
    elif player.velocity.y < 0 and movement_component.on_wall and !movement_component.jumping:
        sprite.play("walk")
    elif movement_component.jumping:
        if on_surface:
            sprite.play("jump")
            on_surface = false
            jump_start = true
        elif jump_start:
            if !sprite.is_playing():
                jump_start = false
        elif player.velocity.y < 0:
            sprite.play("jump_loop")
        else:
            sprite.play("fall")
    elif player.velocity.x != 0:
        sprite.play("walk")
    else:
        sprite.play("idle")

    # Bubble Animations
    if player.velocity != Vector2.ZERO:
        bubble_particles.emitting = true
    else:
        bubble_particles.emitting = false
        
    # Directional Animations
    if player.dashing:
        sprite.rotation = player.dash_dir.angle() + PI / 2
    else:
        # Surface handling
        if player.get_slide_collision_count() > 0:
            var collision = player.get_slide_collision(0)
            var normal = collision.get_normal()
            # Compute the surface angle in radians and apply to sprite
            var angle = atan2(normal.y, normal.x) + PI / 2
            sprite.rotation = angle
        # Mid-air handling
        else:
            var angle_diff = fposmod(0 - sprite.rotation + PI, TAU) - PI
            sprite.rotation = move_toward(sprite.rotation, sprite.rotation + angle_diff, ROT_RESET_SPEED * delta)
    
    if player.facing_left:
        sprite.flip_h = true
    else:
        sprite.flip_h = false
    
    if movement_component.on_ceiling or movement_component.on_wall or player.is_on_floor():
        on_surface = true
