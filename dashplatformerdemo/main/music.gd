extends AudioStreamPlayer

# Music dictionary to store preloaded audio streams
var music_dict: Dictionary = {
    "main" : load("uid://bixtag0udsjxy")
}

# Export variables for customization
@export var fade_in_dur: float = 1.5  # Time (s) for fading in
@export var fade_out_dur: float = 0.5  # Time (s) for fading out

var volume_pct: float = 1.0
var current_music: String = ""

# Called when the node is added to the scene
func _ready() -> void:
    bus = "Music"
    Global.music = self
    connect("finished", Callable(self, "_on_music_finished"))
    play_music("main")

# Play music with a fade-in, and fade out the currently playing music
func play_music(music_key: String) -> void:
    current_music = music_key
    # Fade out current music if necessary
    if playing: await fade_out()
    # Set and fade in the new music
    stream = music_dict[music_key]
    await fade_in()

# Gradually fade out the currently playing music
func fade_out() -> void:
    var initial_volume: float = volume_db
    var steps: int = int(fade_out_dur / 0.1)
    var step_size: float = (initial_volume - -80) / steps
    for i in range(steps):
        volume_db -= step_size
        await get_tree().create_timer(fade_out_dur / steps).timeout
    stop()  # Stop playback after fading out

# Gradually fade in the currently set music
func fade_in() -> void:
    play()  # Start playback
    volume_db = -80
    var steps: int = int(fade_in_dur / 0.1)
    var step_size: float = ((-80 + 80*volume_pct)-volume_db) / steps
    for i in range(steps):
        volume_db += step_size
        await get_tree().create_timer(fade_in_dur / steps).timeout

func _on_music_finished():
    # Loopback current music ( no fade )
    stream = music_dict[current_music]
    play()
