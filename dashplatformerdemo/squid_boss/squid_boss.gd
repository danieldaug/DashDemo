extends Node2D
class_name SquidBoss

signal Died
signal Started
@export var player: Player
@export var squid_body: SquidBody
@export var arms: Array[SquidArm]
@export var left_hitbox: Area2D
@export var right_hitbox: Area2D
@export var health: SquidHealth
@export var attack_timer: Timer
@export var state_timer: Timer
@export var start_door: TileMapLayer
@export var end_door: TileMapLayer

var eyes_changed: int = 0
var active_slaps: Dictionary = {}
var slapping: int = 0

# Arm Manipulation
@onready var vertical_arm_boundary = global_position.y + 800
var arm_angles: Array[float]
@onready var center_point: Vector2 = Vector2(global_position.x, global_position.y + 800)
var sorted_arms: Array[SquidArm]
var wave_slaps: int = 0
var slap_repeats: int = 0

# States
var idle_state: bool = true
var start_idle: bool = true
var random_slap_state: bool = false
var outward_slap_state: bool = false
var wave_slap_state: bool = false
var vertical_slap_state: bool = false
var tantrum_slap_state: bool = false
var start_tantrum: bool = false
var end_tantrum: bool = false
var rotating_state: bool = false
var reset_state: bool = false
var started: bool = false

# Constants
const MIN_RANDOM_SLAP_WAIT: float = 0.75
const MAX_RANDOM_SLAP_WAIT: float = 1.5
const SLOW_WAVE_SLAP_INTERVAL: float = 0.2
const TANTRUM_SLAP_WAIT: float = 0.1

const MIN_IDLE_TIME: float = 1.0
const MAX_IDLE_TIME: float = 2.0
const MIN_RANDOM_SLAP_TIME: float = 3.0
const MAX_RANDOM_SLAP_TIME: float = 4.0
const MIN_ROTATION_TIME: float = 0.25
const MAX_ROTATION_TIME: float = 1.0
const MIN_TANTRUM_TIME: float = 4.0
const MAX_TANTRUM_TIME: float = 6.0
const MIN_VERTICAL_SLAP_TIME: float = 4.0
const MAX_VERTICAL_SLAP_TIME: float = 6.0

const X_RADIUS: float = 650.0
const Y_RADIUS: float = 200.0
const ROTATION_SPEED: float = 2.5

func _ready():
    # Initialize arm manipulation arrarys
    var i = 0
    var size = arms.size()
    for arm in arms:
        active_slaps[arm] = false
        arm.connect("fully_reset", Callable(self, "_arm_reset"))
        var angle = ((TAU / size) + 0.05) * i 
        arm_angles.append(angle)
        var x = cos(angle) * X_RADIUS
        var y = sin(angle) * Y_RADIUS
        arms[i].global_position = center_point + Vector2(x, y)
        arms[i].cur_station = arms[i].global_position
        if y + center_point.y < vertical_arm_boundary and arms[i].is_forward:
            arms[i].switch_vertical()
        elif y + center_point.y > vertical_arm_boundary and !arms[i].is_forward:
            arms[i].switch_vertical()
        i += 1
    # Connections
    if !player:
        player = Global.player
    squid_body.player = player
    health.squid_blood = squid_body.blood
    left_hitbox = squid_body.left_hitbox
    right_hitbox = squid_body.right_hitbox
    left_hitbox.connect("body_entered", Callable(health, "hurt"))
    right_hitbox.connect("body_entered", Callable(health, "hurt"))
    self.connect("Started", Callable(start_door, "close"))
    self.connect("Died", Callable(end_door, "open"))

func _process(delta):
    if !started:
        Started.emit()
        Global.sfx.play("boss_enter", global_position)
        started = true
    # 1st stage state handling
    if eyes_changed == 0:
        if idle_state:
            if start_idle:
                state_timer.start(randf_range(MIN_IDLE_TIME, MAX_IDLE_TIME))
                start_idle = false
        elif random_slap_state: 
            if slapping < 4 and attack_timer.is_stopped():
                attack_timer.start(randf_range(MIN_RANDOM_SLAP_WAIT, MAX_RANDOM_SLAP_WAIT))
        elif rotating_state:
            _rotate(delta)
        elif wave_slap_state:
            pass
    # 2nd stage handling
    elif eyes_changed == 1:
        if idle_state:
            if start_idle:
                state_timer.start(randf_range(MIN_IDLE_TIME, MAX_IDLE_TIME))
                start_idle = false
        elif vertical_slap_state:
            pass
        elif tantrum_slap_state:
            if slapping < 6 and attack_timer.is_stopped():
                if start_tantrum:
                    start_tantrum = false
                    attack_timer.start(TANTRUM_SLAP_WAIT * 5)
                else:
                    attack_timer.start(TANTRUM_SLAP_WAIT)
        elif rotating_state:
            _rotate(delta)
    else:
        if squid_body.on_floor:
            if squid_body.global_position.y >= squid_body.origin.y + 2500:
                queue_free()
        else:
            if squid_body.global_position.y <= squid_body.origin.y - 1500:
                queue_free()

func _idle():
    start_idle = true
    idle_state = true
    squid_body.enter_idle()
    for arm in arms:
        arm.reset()

func _random_slapping():
    random_slap_state = true
    attack_timer.start(randf_range(MIN_RANDOM_SLAP_WAIT, MAX_RANDOM_SLAP_WAIT))

func _rotate(delta: float) -> void:
    for i in arms.size():
        arm_angles[i] += ROTATION_SPEED * delta
        var x = cos(arm_angles[i]) * X_RADIUS
        var y = sin(arm_angles[i]) * Y_RADIUS
        arms[i].global_position = Vector2(x, y) + center_point
        arms[i].cur_station = arms[i].global_position
        if y + center_point.y < vertical_arm_boundary and arms[i].is_forward:
            arms[i].switch_vertical()
        elif y + center_point.y > vertical_arm_boundary and !arms[i].is_forward:
            arms[i].switch_vertical()

func _slow_wave_slap():
    sorted_arms = arms.duplicate()
    var sorter = SortByX.new()
    sorted_arms.sort_custom(sorter.sort)
    var random_choice = randi_range(0,1)
    if random_choice == 0:
        for arm in sorted_arms:
            if !arm.is_forward:
                arm.switch_vertical()
            if arm.global_position.y < vertical_arm_boundary:
                arm.move_to_height(vertical_arm_boundary)
    else:
        for arm in sorted_arms:
            if arm.is_forward:
                arm.switch_vertical()
            if arm.global_position.y > vertical_arm_boundary:

                arm.move_to_height(vertical_arm_boundary)
    attack_timer.start(SLOW_WAVE_SLAP_INTERVAL * 5)

func _vertical_wave_slap():
    sorted_arms = arms.duplicate()
    var sorter = SortByX.new()
    sorted_arms.sort_custom(sorter.sort)
    for arm in sorted_arms:
        arm.vertical_slap()

func _tantrum_slap():
    var random_choice = randi_range(0,1)
    if random_choice == 0:
        for arm in arms:
            if !arm.is_forward:
                arm.switch_vertical()
            if arm.global_position.y < vertical_arm_boundary:
                arm.move_to_height(vertical_arm_boundary)
    else:
        for arm in arms:
            if arm.is_forward:
                arm.switch_vertical()
            if arm.global_position.y > vertical_arm_boundary:
                arm.move_to_height(vertical_arm_boundary)

func _reset():
    random_slap_state = false
    rotating_state = false
    wave_slap_state = false
    _idle()

func hurt():
    squid_body.hurt()

func change_eye():
    _all_arms_reset()
    _reset()
    if eyes_changed >= 1:
        die()
        return
    hurt()
    squid_body.right_eye_switch()
    squid_body.left_eye_switch()
    eyes_changed += 1
    attack_timer.stop()
    state_timer.stop()

func die():
    Global.sfx.play("boss_leave", global_position)
    attack_timer.stop()
    state_timer.stop()
    rotating_state = false
    start_idle = false
    idle_state = false
    tantrum_slap_state = false
    squid_body.enter_die()
    for arm in arms:
        arm.enter_die()
    Died.emit()

func _on_attack_timer_timeout():
    if random_slap_state:
        var found = false
        var local_cur = 0
        while !found:
            var arm_keys = active_slaps.keys()
            var random_arm = arm_keys[randi() % arm_keys.size()]
            if !active_slaps[random_arm]:
                active_slaps[random_arm] = true
                local_cur += 1
                random_arm.start_shake()
                slapping += 1
                if not (local_cur < 3 and slapping < 6):
                    found = true
        if slapping < 4:
            attack_timer.start(randf_range(MIN_RANDOM_SLAP_WAIT, MAX_RANDOM_SLAP_WAIT))
        else:
            attack_timer.stop()
    elif wave_slap_state:
        if wave_slaps < 6:
            sorted_arms[wave_slaps].start_shake()
            wave_slaps += 1
            attack_timer.start(SLOW_WAVE_SLAP_INTERVAL)
        else:
            state_timer.start(4.5)
            attack_timer.stop()
    elif tantrum_slap_state:
        var found = false
        while !found:
            var arm_keys = active_slaps.keys()
            var random_arm = arm_keys[randi() % arm_keys.size()]
            if !active_slaps[random_arm]:
                active_slaps[random_arm] = true
                random_arm.start_shake()
                slapping += 1
                found = true
        if slapping < 6:
            attack_timer.start(TANTRUM_SLAP_WAIT)
        else:
            attack_timer.stop()

func _arm_reset(arm_id):
    slapping = max(0, slapping - 1)
    active_slaps[arm_id] = false

func _all_arms_reset():
    slapping = 0
    wave_slaps = 0
    for arm in active_slaps.keys():
        active_slaps[arm] = false

func _on_state_timer_timeout():
    # State switch on end of state's time
    if idle_state:
        idle_state = false
        if eyes_changed == 0:
            # Switch to rotation or slaps
            var random_choice = randi_range(0,2)
            if random_choice == 0:
                # Prevent to many repetitions of random slap
                slap_repeats += 1
                if slap_repeats >= 3:
                    slap_repeats = 0
                    rotating_state = true
                    state_timer.start(randf_range(MIN_ROTATION_TIME, MAX_ROTATION_TIME))
                else:
                    random_slap_state = true
                    attack_timer.start(0.1)
                    state_timer.start(randf_range(MIN_RANDOM_SLAP_TIME, MAX_RANDOM_SLAP_TIME))
            elif random_choice == 1:
                slap_repeats = 0
                rotating_state = true
                state_timer.start(randf_range(MIN_ROTATION_TIME, MAX_ROTATION_TIME))
            else:
                slap_repeats = 0
                wave_slap_state = true
                _slow_wave_slap()
                state_timer.stop()
        else:
            # Switch to rotation or slaps
            var random_choice = randi_range(0,2)
            if random_choice == 0:
                rotating_state = true
                state_timer.start(randf_range(MIN_ROTATION_TIME, MAX_ROTATION_TIME))
            elif random_choice == 1:
                tantrum_slap_state = true
                start_tantrum = true
                _tantrum_slap()
                state_timer.start(randf_range(MIN_TANTRUM_TIME, MAX_TANTRUM_TIME))
            else:
                slap_repeats += 1
                if slap_repeats >= 3:
                    slap_repeats = 0
                    rotating_state = true
                    state_timer.start(randf_range(MIN_ROTATION_TIME, MAX_ROTATION_TIME))
                else:
                    vertical_slap_state = true
                    _vertical_wave_slap()
                    state_timer.start(randf_range(MIN_VERTICAL_SLAP_TIME, MAX_VERTICAL_SLAP_TIME))
    elif random_slap_state:
        # Enter idle
        random_slap_state = false
        _all_arms_reset()
        _idle()
    elif rotating_state:
        if eyes_changed == 0:
            # Slap immediately after rotating
            rotating_state = false
            random_slap_state = true
            attack_timer.start(0.1)
            state_timer.start(randf_range(MIN_RANDOM_SLAP_TIME, MAX_RANDOM_SLAP_TIME))
        else:
            rotating_state = false
            vertical_slap_state = true
            _vertical_wave_slap()
            state_timer.start(randf_range(MIN_VERTICAL_SLAP_TIME, MAX_VERTICAL_SLAP_TIME))
    elif wave_slap_state:
        _all_arms_reset()
        wave_slap_state = false
        rotating_state = true
        state_timer.start(randf_range(MIN_ROTATION_TIME, MAX_ROTATION_TIME))
    elif tantrum_slap_state:
        state_timer.start(4.5)
        tantrum_slap_state = false
        end_tantrum = true
        _all_arms_reset()
        _idle()
    elif end_tantrum:
        end_tantrum = false
        rotating_state = true
        state_timer.start(randf_range(MIN_ROTATION_TIME, MAX_ROTATION_TIME))
    elif vertical_slap_state:
        for arm in arms:
            arm.end_vertical_slap()
        vertical_slap_state = false
        _idle()
    else:
        _idle()
