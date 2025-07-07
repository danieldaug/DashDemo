extends CenterContainer

@export var ink_origins: Array[Marker2D]
@export var drop_timer: Timer
@export var bubbles: GPUParticles2D
var ink_drop_instance: PackedScene = preload("uid://kpqyfbym0ey0")

var fall_speed = 500.0  # pixels per second
var target_y = 175.0
var is_floating = false
var bobbing_time = 0.0

# Floating config
var bobbing_amplitude = 8.0  # pixels
var bobbing_speed = 0.35  # oscillations per second
var sway_amplitude = 3.0  # degrees
var sway_speed = 0.25  # oscillations per second

# Constants
const MIN_DROP_WAIT: float = 3.0
const MAX_DROP_WAIT: float = 5.0

func _process(delta):
    if not is_floating:
        # Fall downward
        position.y += fall_speed * delta
        if position.y >= target_y:
            position.y = target_y
            is_floating = true
            bobbing_time = 0.0
    else:
        # Bobbing and swaying motion
        bobbing_time += delta
        var bob_y = sin(bobbing_time * bobbing_speed * TAU) * bobbing_amplitude
        var sway_angle = sin(bobbing_time * sway_speed * TAU) * sway_amplitude

        position.y = target_y + bob_y
        rotation_degrees = sway_angle

func _on_drop_timer_timeout():
    var ink_drop = ink_drop_instance.instantiate()
    ink_drop.position = ink_origins[randi_range(0, 2)].position
    if randi_range(0, 1) == 1:
        ink_drop.flip_h = true
    get_tree().root.add_child(ink_drop)
    drop_timer.start(randf_range(MIN_DROP_WAIT, MAX_DROP_WAIT))
