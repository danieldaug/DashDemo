extends State
class_name Dashing

@export var player: Player
@export var dash_particles: GPUParticles2D

# Dash Factors
var dash_dir: Vector2
var collision: KinematicCollision2D
var dash_velocity: Vector2
var jelly_factor: float = 1.0
var redash: bool = false

# Inital Rotation
var rotating: bool = true
var target_angle: float = 0.0
var target_rotation: float = 0.0

# Constants
const ROTATION_SPEED: float = 5.0
const DASH_SPEED: float = 750.0
const COOLDOWN_TIME: float = 0.2

func Enter():
    # Dash UI
    #var tween = create_tween()
    #tween.tween_property(Global.ui.dashbar, "value", 0, 0.2)
    player.desaturate()
    # Initial aim setting
    dash_dir = player.dash_aim
    target_angle = dash_dir.angle() + PI / 2
    # Ink
    if not dash_particles.emitting:
        dash_particles.emitting = true

func dash():
    if redash:
        #Global.ui.dashbar.value = 15
        var input_vector = Vector2(
            Input.get_action_strength("right") - Input.get_action_strength("left"),
            Input.get_action_strength("down") - Input.get_action_strength("up")
        )

        player.dash_aim = input_vector.normalized() if input_vector.length() > 0 else Vector2.ZERO
    
        if player.dash_aim != Vector2.ZERO and Input.is_action_just_pressed("dash"):
            player.desaturate()
            redash = false
            rotating = true
            Enter()

func Physics_Update(delta: float):
    if rotating:
        target_rotation = lerp_angle(target_rotation, target_angle, ROTATION_SPEED * delta)  # Smooth transition
        dash_particles.global_rotation = target_rotation
        if abs(target_rotation - target_angle) < 0.1:
            rotating = false
    
    # Moving and collision check
    dash_velocity = dash_dir * DASH_SPEED * delta * jelly_factor
    collision = player.move_and_collide(dash_velocity)
    if collision:
        player.velocity = Vector2.ZERO
        # Set OnSurface state to have proper surface state
        var normal = collision.get_normal()
        if normal.dot(Vector2.LEFT) > 0.7 or normal.dot(Vector2.RIGHT) > 0.7:
            player.state_machine.states["OnSurface"].surface_type = player.state_machine.states["OnSurface"].SurfaceType.WALL
            if normal.dot(Vector2.LEFT) > 0.7:
                player.global_position.x += 3
            else:
                player.global_position.x -= 3
        elif normal.dot(Vector2.UP) > 0.7:
            player.state_machine.states["OnSurface"].surface_type = player.state_machine.states["OnSurface"].SurfaceType.FLOOR
        elif normal.dot(Vector2.DOWN) > 0.7:
            player.state_machine.states["OnSurface"].surface_type = player.state_machine.states["OnSurface"].SurfaceType.CEILING
        Transitioned.emit(self, "OnSurface")
    
    # Potential re-dash
    dash()

func Exit():
    # Dash UI
    #var tween = create_tween()
    #tween.tween_property(Global.ui.dashbar, "value", 15, 0.2)
    player.saturate()
    dash_particles.emitting = false
    redash = false
    rotating = true
    jelly_factor = 1.0
    player.dash_cooldown.start(COOLDOWN_TIME)
