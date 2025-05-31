extends Node
class_name AnimationComponentR

@export var player: Player
@export var sprite: AnimatedSprite2D
@export var bubble_particles: GPUParticles2D
@export var on_surface_state: OnSurface
@export var off_surface_state: OffSurface

var cur_state: String = "OnSurface"
var has_handled_rotation: bool = false

# Constants
const ROT_RESET_SPEED: float = 10.0

func dash_animations():
    sprite.play("dash")

func off_surface_animations():
    # Prioritize bounce animation
    if off_surface_state.bouncing:
        sprite.play("fall")
    elif player.velocity.y < 0:
        sprite.play("jump_loop")
    else:
        sprite.play("fall")
    # Sprite direction
    if player.velocity.x > 0:
        sprite.flip_h = false
    elif player.velocity.x < 0:
        sprite.flip_h = true

func on_surface_animations():
    # Init Jump Animation
    if on_surface_state.jumped:
        if player.velocity.x > 0:
            sprite.flip_h = false
        elif player.velocity.x < 0:
            sprite.flip_h = true
        sprite.play("jump")
    # Surface Animations
    elif (player.velocity.y > 0 and on_surface_state.wall_left) or (player.velocity.y < 0 and !on_surface_state.wall_left) or (on_surface_state.surface_type != on_surface_state.SurfaceType.CEILING and player.velocity.x > 0) or(on_surface_state.surface_type == on_surface_state.SurfaceType.CEILING and player.velocity.x < 0):
        sprite.flip_h = false
        sprite.play("walk")
    elif player.velocity != Vector2.ZERO:
        sprite.flip_h = true
        sprite.play("walk")
    else:
        sprite.play("idle")

func sprite_rotation(delta: float):
    var angle: float = -1.0
    if cur_state == "OnSurface":
        if player.get_slide_collision_count() > 0 and !has_handled_rotation:
            var collision = player.get_slide_collision(0)
            var normal = collision.get_normal()
            # Compute the surface angle in radians and apply to sprite
            angle = atan2(normal.y, normal.x) + PI / 2
            sprite.rotation = angle
            has_handled_rotation = true
    elif cur_state == "OffSurface":
        # Rotate back to upright
        var angle_diff = fposmod(0 - sprite.rotation + PI, TAU) - PI
        sprite.rotation = move_toward(sprite.rotation, sprite.rotation + angle_diff, ROT_RESET_SPEED * delta)
    else:
        # Rotate towards dash direction
        sprite.rotation = player.state_machine.states["Dashing"].dash_dir.angle() + PI / 2

func _process(delta):
    has_handled_rotation = false
    if cur_state == "OnSurface":
        on_surface_animations()
    elif cur_state == "OffSurface":
        off_surface_animations()
    else:
        dash_animations()
        
    sprite_rotation(delta)
    
    if player.velocity != Vector2.ZERO:
        bubble_particles.emitting = true
    else:
        bubble_particles.emitting = false
