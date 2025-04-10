extends CharacterBody2D
class_name Player

@export var movement_component: MovementComponent
@export var dash_component: DashComponent
@export var health_component: HealthComponent
@export var sprite: AnimatedSprite2D
@export var camera: Camera2D

var facing_left: bool = false
var dashing: bool: set = dash_change
var dash_collision: bool = false
var dash_dir: Vector2
var dash_collision_timer: Timer = Timer.new()
var last_spawn: Vector2 = Vector2(0, 0)

# Constants
const DASH_COLLISION_DELAY: float = 0.2

func _ready():
    Global.player = self
    dashing = false
    dash_collision_timer.one_shot = true
    dash_collision_timer.timeout.connect(collision_timeout)
    add_child(dash_collision_timer)

func _process(_delta):
    if movement_component.on_wall:
        if movement_component.wall_left:
            if velocity.y > 0:
                facing_left = false
            elif velocity.y < 0:
                facing_left = true
        else:
            if velocity.y < 0:
                facing_left = false
            elif velocity.y > 0:
                facing_left = true
    elif movement_component.on_ceiling:
        if velocity.x < 0:
            facing_left = false
        elif velocity.x > 0:
            facing_left = true
    else:
        if velocity.x > 0:
            facing_left = false
        elif velocity.x < 0:
            facing_left = true

func dash_change(value: bool) -> void:
    if value:
        dash_collision = true
        dashing = true
        movement_component.in_jelly = false
    else:
        dashing = false
        dash_collision_timer.start(DASH_COLLISION_DELAY)

func collision_timeout() -> void:
    dash_collision = false
    
func respawn() -> void:
    await Global.ui.fade_out()
    velocity = Vector2.ZERO
    dashing = false
    movement_component.bouncing = false
    dash_component.dashing = false
    dash_component.can_dash = true
    dash_component.dash_particles.emitting = false
    global_position = last_spawn
    health_component.health = health_component.max_health
    Global.ui.change_health(health_component.health)
    await Global.ui.fade_in()
