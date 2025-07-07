extends CenterContainer

@export var button: Button
var appeared: bool = false

func appear():
    position.x = 0
    await get_tree().create_timer(1.0).timeout
    var tween = create_tween()
    tween.tween_property(self, "modulate:a", 1.0, 1.0)
    appeared = true
    button.grab_focus()
