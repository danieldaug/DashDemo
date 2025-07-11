extends Area2D

@export var level: Level

func _on_body_entered(body):
    if body is Player:
        var tween = get_tree().root.create_tween()
        tween.tween_property(level.canvas_modulate, "color:v", 0.6, 3.0)

func _on_body_exited(body):
    if body is Player:
        var tween = create_tween()
        tween.tween_property(level.canvas_modulate, "color:v", 0.95, 3.0)
