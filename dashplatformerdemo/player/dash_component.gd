extends Node
class_name DashComponent

@export var player: Player
@export var movement_comp: MovementComponent
@export var dash_particles: GPUParticles2D
@export var cooldown_timer: Timer

var cur_direction: Vector2
var dash_direction: Vector2
var dashing: bool = false
var can_dash: bool = true
var in_jelly: bool = false
var target_rotation: float = 0.0

const DASH_SPEED: float = 750.0
const JELLY_SPEED: float = 200.0
const COOLDOWN_TIME: float = 0.1

func _ready():
    pass

func _physics_process(delta):
    
    var input_vector = Vector2(
        Input.get_action_strength("right") - Input.get_action_strength("left"),
        Input.get_action_strength("down") - Input.get_action_strength("up")
    )

    cur_direction = input_vector.normalized() if input_vector.length() > 0 else Vector2.ZERO
    
    if cur_direction != Vector2.ZERO and Input.is_action_just_pressed("dash") and can_dash and !movement_comp.bouncing:
        dashing = true
        player.dashing = true
        movement_comp.on_wall = false
        movement_comp.on_ceiling = false
        can_dash = false
        dash_direction = cur_direction
        dash_particles.global_rotation = dash_direction.angle() + PI / 2
        if not dash_particles.emitting:
            dash_particles.emitting = true
        player.dash_dir = dash_direction
        movement_comp.wall_left = dash_direction.normalized().x < 0
        movement_comp.cur_speed = 0
        movement_comp.cur_jump_speed = 0
    
    if dashing:
        var target_angle = dash_direction.angle() + PI / 2
        target_rotation = lerp_angle(target_rotation, target_angle, 5.0 * delta)  # Smooth transition
        dash_particles.global_rotation = target_rotation
        var collision: KinematicCollision2D
        var dash_velocity: Vector2
        if in_jelly:
            dash_velocity = dash_direction * JELLY_SPEED * delta
        else:
            dash_velocity = dash_direction * DASH_SPEED * delta
        collision = player.move_and_collide(dash_velocity)
        if collision:
            player.velocity = Vector2.ZERO
            dashing = false
            player.dashing = false
            movement_comp.falling = false
            movement_comp.cur_speed = 0
            movement_comp.cur_jump_speed = 0
            if collision.get_normal().y > 0.9:
                movement_comp.on_ceiling = true
                movement_comp.ceiling_pos = player.global_position.y
            elif abs(collision.get_normal().x) > 0.9:
                player.global_position += collision.get_remainder() * 0.9
                movement_comp.on_wall = true
                movement_comp.wall_pos = player.global_position.x
            dash_particles.emitting = false
            cooldown_timer.start(COOLDOWN_TIME)

func _on_dash_cooldown_timeout():
    can_dash = true
