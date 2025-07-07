extends Control

@export var transition_rect: ColorRect
@export var master_slider: HSlider
@export var music_slider: HSlider
@export var sfx_slider: HSlider
@export var play_sfx_timer: Timer

# Constants
const PLAY_SFX_WAIT: float = 0.5

func _ready():
    master_slider.value = Global.master_vol
    music_slider.value = Global.music_vol
    sfx_slider.value = Global.sfx_vol
    var fade = create_tween()
    fade.tween_method(set_alpha, 1.0, 0.0, 0.5)
    var ripple = create_tween()
    ripple.tween_method(func(r): transition_rect.material.set_shader_parameter("ripple_radius", r), 1.5, 0.0, 0.5)
    await ripple.finished

func _on_return_button_pressed():
    menu_fade(Global.main_menu)

func menu_fade(next_scene: PackedScene) -> void:
    Global.sfx.play("transition_water")
    var fade = create_tween()
    fade.tween_method(set_alpha, 0.0, 1.0, 0.5)

    # Animate ripple outward
    var ripple = create_tween()
    ripple.tween_method(func(r): transition_rect.material.set_shader_parameter("ripple_radius", r), 0.0, 1.5, 0.5)
    await ripple.finished

    SceneScript.switch_scene(next_scene)

func set_alpha(a: float) -> void:
    transition_rect.material.set_shader_parameter("alpha", a)

func master_value_changed(value):
    AudioServer.set_bus_volume_db(0, ((value / 100.0) * 40) - 20)
    Global.master_vol = value

func music_value_changed(value):
    Global.music.volume_db = ((value / 100.0) * 40) - 20
    Global.music_vol = value

func sfx_value_changed(value):
    Global.sfx.volume_pct = ((value / 200.0) + 0.75)
    Global.sfx_vol = value
    play_sfx_timer.start(PLAY_SFX_WAIT)

func _on_play_sfx_timer_timeout():
    Global.sfx.play("move")
