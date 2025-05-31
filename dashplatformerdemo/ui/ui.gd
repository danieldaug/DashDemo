extends CanvasLayer
class_name UI

@export var transition_rect: ColorRect
@export var healthbar: TextureProgressBar
@export var dashbar: TextureProgressBar
@export var darkness: ColorRect

func _ready():
    Global.ui = self
    # Connections after inital ready processes
    await get_tree().process_frame
    healthbar.max_value = Global.player.health_component.max_health
    healthbar.value = Global.player.health_component.health

func change_health(value: float) -> void:
    healthbar.value = value
    
func death() -> void:
    pass

func fade_out() -> void:
    # Prevent movement during transition
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
