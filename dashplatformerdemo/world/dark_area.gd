extends Area2D

func _on_body_entered(body):
    if body is Player:
        var tween = get_tree().root.create_tween()
        tween.tween_property(Global.ui.darkness, "modulate:a", 0.4, 3.0)

func _on_body_exited(body):
    if body is Player:
        var tween = create_tween()
        tween.tween_property(Global.ui.darkness, "modulate:a", 0, 3.0)
