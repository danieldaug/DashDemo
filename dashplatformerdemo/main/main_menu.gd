extends Control

@export var transition_rect: ColorRect

func _ready():
    if Global.entered_scene:
        print("here")
        var fade = create_tween()
        fade.tween_method(set_alpha, 1.0, 0.0, 0.5)
        var ripple = create_tween()
        ripple.tween_method(func(r): transition_rect.material.set_shader_parameter("ripple_radius", r), 1.5, 0.0, 0.5)
    else:
        transition_rect.material.set_shader_parameter("alpha", 0.0)

func _on_start_button_pressed():
    menu_fade(Global.level_1)

func _on_options_button_pressed():
    menu_fade(Global.options_menu)

func menu_fade(next_scene: PackedScene) -> void:
    Global.sfx.play("transition_water")
    Global.entered_scene = true
    var fade = create_tween()
    fade.tween_method(set_alpha, 0.0, 1.0, 0.5)

    # Animate ripple outward
    var ripple = create_tween()
    ripple.tween_method(func(r): transition_rect.material.set_shader_parameter("ripple_radius", r), 0.0, 1.5, 0.5)
    await ripple.finished
    
    SceneScript.switch_scene(next_scene)

func set_alpha(a: float) -> void:
    transition_rect.material.set_shader_parameter("alpha", a)

func _on_close_button_pressed():
    get_tree().quit()
