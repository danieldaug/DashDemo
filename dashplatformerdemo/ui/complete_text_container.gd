extends CenterContainer

# Floating config
var bobbing_amplitude: float = 4.0  # pixels
var bobbing_speed: float  = 0.3  # oscillations per second
var sway_amplitude: float  = 1.0  # degrees
var sway_speed: float  = 0.25 # oscillations per second
var bobbing_time: float  = 0.0
var target_y = 186.0

func appear():
    scale = Vector2(0.1, 0.1)
    var tween = create_tween()
    tween.tween_property(self, "scale", Vector2(1, 1), 0.5)
    visible = true

func disappear():
    visible = false

func _process(delta):
    # Bobbing and swaying motion
    bobbing_time += delta
    var bob_y = sin(bobbing_time * bobbing_speed * TAU) * bobbing_amplitude
    var sway_angle = sin(bobbing_time * sway_speed * TAU) * sway_amplitude

    position.y = bob_y + target_y
    rotation_degrees = sway_angle
