extends Node2D

@export var attack_timer: Timer
@export var bubble_timer: Timer
@export var sprite: AnimatedSprite2D
@export var area: Area2D

var hiding: bool = true
var attacking: bool = false
var start_attack: bool = false
var bubble_instance: PackedScene = preload("res://crab/crab_bubble.tscn")
var cur_bubble_type: int = 1

# Constants
const MAX_PAUSE: float = 5.0
const MIN_PAUSE: float = 3.0
const MIN_ATTACK_TIME: float = 5.0
const MAX_ATTACK_TIME: float = 8.0
const TYPE_1_PAUSE: float = 0.5

func _ready():
    sprite.play("hide")
    attack_timer.start(randf_range(MIN_PAUSE, MAX_PAUSE))
    
func _physics_process(delta: float):
    if !hiding and !attacking:
        if !sprite.is_playing():
            sprite.play("attack_start")
            attacking = true
            start_attack = true
            attack_timer.start(randf_range(MIN_ATTACK_TIME, MAX_ATTACK_TIME))
            cur_bubble_type = randi_range(1, 1)
    elif start_attack:
        start_attack = false
        bubble_attack(cur_bubble_type)
    elif attacking:
        if !sprite.is_playing():
            sprite.play("attack")

func _on_area_2d_body_entered(body: Node2D):
    if body is Player:
        if body.dashing:
            var tween = self.create_tween()
            tween.tween_method(reduce_blink, 1.0, 0.0, 1.0)
            attacking = false
            hiding = true
            sprite.play("hide")
            area.queue_free()
            attack_timer.stop()
        else:
            body.health_component.damage(1)

func reduce_blink(new_val: float) -> void:
    sprite.material.set_shader_parameter("blink_intensity", new_val)

func _on_attack_timer_timeout():
    if hiding:
        sprite.play("unhide")
        hiding = false
    else:
        attacking = false
        hiding = true
        sprite.play("hide")
        bubble_timer.stop()
        attack_timer.start(randf_range(MIN_PAUSE, MAX_PAUSE))

func bubble_attack(attack_type: int):
    if attack_type == 1:
        var bubble_instance: Node2D = bubble_instance.instantiate()
        var random_angle: float = deg_to_rad(-90.0 + randf_range(-45.0 / 2, 45.0 / 2))
        bubble_instance.direction = Vector2(cos(random_angle), sin(random_angle)).normalized()
        bubble_instance.global_position = global_position + Vector2(0, -10)
        get_tree().root.add_child(bubble_instance)
        bubble_timer.start(TYPE_1_PAUSE)
        
        
func _on_bubble_timer_timeout():
    bubble_attack(cur_bubble_type)
