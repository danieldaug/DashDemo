extends Node2D

@export var facing_left: bool = false
@export var sprite: Sprite2D

@onready var speed: float = randf_range(20, 150)
@onready var init_pos: float = global_position.x

func _ready():
    if facing_left:
        sprite.flip_h = true
    sprite.frame = randi_range(0, 3)
    modulate.a = 0
    var tween = create_tween()
    tween.tween_property(self, "modulate:a", randf_range(0.2, 0.4), 1.0)
    
func _physics_process(delta):
    if facing_left:
        global_position.x -= speed * delta
        if global_position.x < init_pos - 1000:
            var tween = create_tween()
            tween.tween_property(self, "modulate:a", 0, 1.0)
            await tween.finished
            queue_free()
    else:
        global_position.x += speed * delta
        if global_position.x > init_pos + 1000:
            var tween = create_tween()
            tween.tween_property(self, "modulate:a", 0, 1.0)
            await tween.finished
            queue_free()
