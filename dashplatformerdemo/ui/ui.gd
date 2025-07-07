extends CanvasLayer
class_name UI

@export var transition_rect: ColorRect
@export var healthbar: TextureProgressBar
@export var dashbar: TextureProgressBar
@export var darkness: ColorRect
@export var complete_text_container: CenterContainer
@export var return_container: CenterContainer
@export var pause_container: CenterContainer
@export var pause_panel: Panel
@export var resume_button: Button

var is_transitioning: bool = false
var paused: bool = false

func _ready():
    transition_rect.material.set_shader_parameter("alpha", 1.5)
    fade_in()
    Global.ui = self
    # Connections after inital ready processes
    await get_tree().process_frame
    healthbar.max_value = Global.player.health_component.max_health
    healthbar.value = Global.player.health_component.health
    return_container.position.x = -1000
    pause_panel.material.set_shader_parameter("viewport_size", get_viewport().get_visible_rect().size)

func change_health(value: float) -> void:
    healthbar.value = value
    
func death() -> void:
    pass

func fade_out(respawning: bool) -> void:
    # Prevent movement during transition
    Global.sfx.play("transition_water")
    if respawning:
        Global.player.state_machine.current_state.process_mode = Node.PROCESS_MODE_DISABLED
    # Fade alpha in
    var fade = create_tween()
    fade.tween_method(set_alpha, 0.0, 1.0, 0.5)

    # Animate ripple outward
    var ripple = create_tween()
    ripple.tween_method(func(r): transition_rect.material.set_shader_parameter("ripple_radius", r), 0.0, 1.5, 0.5)
    await ripple.finished

func fade_in() -> void:
    Global.player.state_machine.current_state.process_mode = Node.PROCESS_MODE_INHERIT
    # Current player action cancellation
    Global.player.velocity = Vector2.ZERO
    Global.player.global_position = Global.player.last_spawn
    Global.player.state_machine.on_transition(Global.player.state_machine.states["Dashing"], "OnSurface")
    Global.player.state_machine.states["OnSurface"].surface_type = Global.player.state_machine.states["OnSurface"].SurfaceType.FLOOR
    # Fade alpha in
    var fade = create_tween()
    fade.tween_method(set_alpha, 1.0, 0.0, 0.5)

    # Animate ripple outward
    var ripple = create_tween()
    ripple.tween_method(func(r): transition_rect.material.set_shader_parameter("ripple_radius", r), 1.5, 0.0, 0.5)
    await ripple.finished

func set_alpha(a: float) -> void:
    transition_rect.material.set_shader_parameter("alpha", a)

func _on_return_button_pressed():
    pause_container.visible = false
    await fade_out(false)
    Global.player.last_spawn = Vector2(-100, -15)
    if not Global.main_menu:
        print("Error no menu!")
    SceneScript.switch_scene(Global.main_menu)
    
func _input(event):
    if event.is_action_pressed("pause"):
        if !Global.player.controls_disabled:
            Global.player.disable_enable()
        pause_container.visible = true
        resume_button.grab_focus()

func _on_respawn_button_pressed():
    pause_container.visible = false
    Global.player.respawn()
    if Global.player.controls_disabled:
        Global.player.disable_enable()

func _on_resume_button_pressed():
    if Global.player.controls_disabled:
        Global.player.disable_enable()
    pause_container.visible = false   
