extends Node
class_name HealthComponent

@export var player: Player
@export var iframe_timer: Timer

var max_health: float = 5
var health: float = 5
var can_hurt = true

# Constants
const IFRAME_TIME: float = 0.5

func _ready():
    iframe_timer.connect("timeout", Callable(self, "allow_damage"))

func damage(amount: float) -> void:
    if can_hurt:
        can_hurt = false
        health -= amount
        if health <= 0:
            player.respawn()
        else:
            Global.ui.change_health(health)
            player.cam_shake = true
        iframe_timer.start(IFRAME_TIME)
        var tween = self.create_tween()
        player.sprite.material.set_shader_parameter("blinking", true)
        tween.tween_method(reduce_blink, 1.0, 0.0, 0.5)
        await tween.finished
        player.sprite.material.set_shader_parameter("blinking", false)

func allow_damage():
    can_hurt = true

func reduce_blink(new_val: float) -> void:
    player.sprite.material.set_shader_parameter("blink_intensity", new_val)
