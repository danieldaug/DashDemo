extends Node2D
class_name Mollusk

@export_category("Nodes")
@export var sprite: AnimatedSprite2D
@export var hitbox: Area2D
@export var shell_collision: StaticBody2D
@export var hurtbox: Area2D

@export_category("Properties")
@export var facing_left: bool = false
@export var starting_rotation: float = 0.0

var player_contact: bool = false
var player: Player

const ROTATION_VELOCITY: float = 1.0

func _ready() -> void:
    if hitbox:
        hitbox.connect("body_entered", Callable(self, "on_hit"))
    if hurtbox:
        hurtbox.connect("body_entered", Callable(self, "on_hurt"))
        hurtbox.connect("body_exited", Callable(self, "stop_hurt"))
    if facing_left:
        sprite.flip_h = true
        hitbox.get_node("CollisionShape").position.x *= -1
    rotation = starting_rotation

func _physics_process(delta):
    rotation = move_toward(rotation, rotation + deg_to_rad(ROTATION_VELOCITY * 100), ROTATION_VELOCITY * delta)
    if player_contact:
        player.health_component.damage(1)

func on_hit(body: Node2D) -> void:
    if body is Player:
        if body.state_machine.current_state == body.state_machine.states["Dashing"] or !body.dash_cooldown.is_stopped():
            sprite.play("hide")
            hitbox.collision_layer = 0
            hitbox.collision_mask = 0
            hurtbox.queue_free()
            var tween = self.create_tween()
            tween.tween_method(reduce_blink, 1.0, 0.0, 1.0)

func on_hurt(body: Node2D) -> void:
    if body is Player:
        player_contact = true
        player = body

func stop_hurt(body: Node2D) -> void:
    if body is Player:
        player_contact = false
        
func reduce_blink(new_val: float) -> void:
    sprite.material.set_shader_parameter("blink_intensity", new_val)
