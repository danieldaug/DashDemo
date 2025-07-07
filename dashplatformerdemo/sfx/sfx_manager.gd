extends Node
class_name SFXManager
# sfx_manager.gd
# Handles a pool of audiostreams to play overlapping audio from randomized sets

const MAX_PLAYERS = 48 # maximum audio players in the pool
var audio_pool: Array[AudioStreamPlayer2D] = []
var looping_players: Dictionary = {}
var volume_pct: float = 1.0

func _ready() -> void:
    Global.sfx = self

func _process(_delta):
    for key in playing_audios:
        playing_audios[key] = playing_audios[key].filter(func(p): return p.playing)

# plays sound by name
func play(sfx_name: String, position: Vector2 = Vector2.ZERO) -> void:
    if position == Vector2.ZERO and Global.player:
        position = Global.player.global_position
    # Downcast to AudioStreamWAV to access loop data
    var stream: AudioStream = get_random_sound(sounds[sfx_name]) as AudioStream
    if not stream:
        return

    #var looping: bool = stream.loop_mode != AudioStreamWAV.LOOP_DISABLED

    # This sound is already looping
    #if looping and looping_players.has(sfx_name):
        #return

    var player = get_free_audio_player()
    if not player:
        return
    player.volume_db = (-80 + 80 * volume_pct)
    playing_audios[sfx_name].append(player)
    player.stream = stream
    player.bus = "FX"
    player.global_position = position
    player.play()

    # # Store reference if it's a looping sound
    #if looping:
        #looping_players[sfx_name] = player

# stops a looping sound by name
func stop(sfx_name: String) -> void:
    if looping_players.has(sfx_name):
        looping_players[sfx_name].stop()
        looping_players.erase(sfx_name)
    if playing_audios[sfx_name]:
        for audio in playing_audios[sfx_name]:
            audio.stop()

# gets random AudioStream from the sound data
func get_random_sound(sound_list: Array) -> AudioStream:
    if sound_list.size() == 0: return null
    return sound_list[randi() % sound_list.size()]

# gets a free AudioStreamPlayer, creates one if pool isn't maxed
func get_free_audio_player() -> AudioStreamPlayer2D:
    for player in audio_pool:
        if not player.playing:
            return player

    if audio_pool.size() < MAX_PLAYERS:
        var new_player = AudioStreamPlayer2D.new()
        add_child(new_player)
        audio_pool.append(new_player)
        return new_player

    return null

func stop_all_loops() -> void:
    # Stop all players
    for player in audio_pool:
        # if its a looper
        if player in looping_players.values(): player.stop()
    # Clear looping players
    looping_players.clear()

# Sound dictionary ----------------------------------------------

var sounds: Dictionary = {
    # Player
    "move" : [load("uid://d3uvom471yx7a")],
    "hurt" : [load("uid://dmjf46oxk8i40")],
    "dash" : [load("uid://b0i2byyr7su3e")],
    "land" : [load("uid://c357kmfl5benv")],
    "spike_land" : [load("uid://brlmusd4om4he")],
    "transition_water" : [load("uid://cvcmkden08xpb")],
    # Mobs/objects
    "bubbles": [load("uid://k18g50ykado0")],
    "chest": [load("uid://ssf83cqe1mjl")],
    "coins": [load("uid://bpvcpwc8rowq1")],
    "mollusk_hit": [load("uid://b1eaqg1jcsrpl")],
    "jelly_hit": [load("uid://dc1mep3jxtnxr")],
    "eel": [load("uid://bae6tigco55gi")],
    "level_complete" : [load("uid://ctgjjrk0tr8es")],
    # Boss
    "boss_enter": [load("uid://c68at58et3upm")],
    "boss_hurt": [load("uid://e3tsjy1i4hv2")],
    "boss_leave": [load("uid://bul3pj4ybfhw")],
    "boss_thump": [load("uid://xb642x16x4xl")],
    "boss_move": [load("uid://uv5b85i2g60k")]
}

var playing_audios: Dictionary = {
    # Player
    "move" : [],
    "hurt" : [],
    "dash" : [],
    "land" : [],
    "spike_land" : [],
    "transition_water" : [],
    # Mobs/objects
    "bubbles": [],
    "chest": [],
    "coins": [],
    "mollusk_hit": [],
    "jelly_hit": [],
    "eel": [],
    "level_complete": [],
    # Boss
    "boss_enter": [],
    "boss_hurt": [],
    "boss_leave": [],
    "boss_thump": [],
    "boss_move": []
}
