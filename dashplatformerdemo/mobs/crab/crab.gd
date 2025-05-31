extends Node2D

@export var attack_timer: Timer
@export var bubble_timer: Timer
@export var sprite: AnimatedSprite2D
@export var area: Area2D
@export var attack_type: int = 0

var hiding: bool = true
var attacking: bool = false
var start_attack: bool = false
var dead: bool = false
var bubble_scene: PackedScene = preload("uid://rfvavlandg72")
var cur_bubble_type: int = 1
var type_3_count: int = 0

# Constants
const MAX_PAUSE: float = 5.0
const MIN_PAUSE: float = 3.0
const MIN_ATTACK_TIME: float = 10.0
const MAX_ATTACK_TIME: float = 20.0
const TYPE_1_PAUSE: float = 0.1
const TYPE_2_PAUSE: float = 0.5
const TYPE_3_PAUSE_1: float = 0.3
const TYPE_3_PAUSE_2: float = 4.0

func _ready():
    sprite.play("hide")
    attack_timer.start(randf_range(MIN_PAUSE, MAX_PAUSE))
    
func _physics_process(_delta: float):
    if dead:
        return
    if !hiding and !attacking:
        if !sprite.is_playing():
            sprite.play("attack_start")
            attacking = true
            start_attack = true
            attack_timer.start(randf_range(MIN_ATTACK_TIME, MAX_ATTACK_TIME))
            if attack_type == 0:
                cur_bubble_type = randi_range(1, 3)
            else:
                cur_bubble_type = attack_type
    elif start_attack:
        start_attack = false
        bubble_attack(cur_bubble_type)
    elif attacking:
        if !sprite.is_playing():
            sprite.play("attack")

func _on_area_2d_body_entered(body: Node2D):
    if body is Player:
        if !hiding:
            if body.state_machine.current_state == body.state_machine.states["Dashing"]:
                dead = true
                var tween = self.create_tween()
                tween.tween_method(reduce_blink, 1.0, 0.0, 1.0)
                hiding = true
                attacking = false
                sprite.play("hide")
                area.queue_free()
                attack_timer.stop()
                bubble_timer.stop()
            else:
                body.health_component.damage(1)

func reduce_blink(new_val: float) -> void:
    sprite.material.set_shader_parameter("blink_intensity", new_val)

func _on_attack_timer_timeout():
    if hiding:
        sprite.play("unhide")
        hiding = false
    else:
        hiding = true
        attacking = false
        sprite.play("hide")
        attack_timer.start(randf_range(MIN_PAUSE, MAX_PAUSE))
        bubble_timer.stop()

func bubble_attack(type: int):
    var bubble_instance: Node2D
    if type == 1:
        bubble_instance = bubble_scene.instantiate()
        var random_angle: float = deg_to_rad(-90.0 + randf_range(-45.0, 45.0))
        bubble_instance.direction = Vector2(cos(random_angle), sin(random_angle)).normalized()
        bubble_instance.position = Vector2(randf_range(-15, 15), -10)
        bubble_instance.speed = 50
        add_child(bubble_instance)
        bubble_timer.start(TYPE_1_PAUSE)
    elif type == 2:
        for i in range(3):
            bubble_instance = bubble_scene.instantiate()
            bubble_instance.position = Vector2((i-1) * 25, -10)
            bubble_instance.speed = -0.25
            bubble_instance.spiraling = true
            bubble_instance.expansion_rate = 50.0
            bubble_instance.angle = -9.75 + i * 1
            add_child(bubble_instance)
        bubble_timer.start(TYPE_2_PAUSE)
    else:
        for i in range(5):
            bubble_instance = bubble_scene.instantiate()
            bubble_instance.position = Vector2((i-2) * 20, -10)
            bubble_instance.speed = 75
            bubble_instance.expansion_rate = 50.0
            var angle: float = deg_to_rad(-180.0 + i * 45)
            bubble_instance.direction = Vector2(cos(angle), sin(angle)).normalized()
            add_child(bubble_instance)
        type_3_count += 1
        if type_3_count >= 30:
            bubble_timer.start(TYPE_3_PAUSE_2)
            type_3_count = 0
        else:
            bubble_timer.start(TYPE_3_PAUSE_1)
        
        
func _on_bubble_timer_timeout():
    bubble_attack(cur_bubble_type)
