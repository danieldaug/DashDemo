extends Node
class_name SquidHealth
@export var squid_boss: SquidBoss
@export var squid_blood: GPUParticles2D
@export var iframe_timer: Timer

signal eye_damage()
signal eye_death()

var health: float = 60.0
var can_hurt: bool = true
var dash_post_hurt: bool = false
var redashable: bool = false
var dead: bool = false

# Constants
const IFRAME_TIME: float = 0.25

func _process(_delta):
    if squid_boss.player.state_machine.current_state != squid_boss.player.state_machine.states["Dashing"]:
        dash_post_hurt = false
        redashable = false
    elif dash_post_hurt and squid_boss.player.state_machine.states["Dashing"].redash:
        redashable = true
    elif dash_post_hurt and redashable and !squid_boss.player.state_machine.states["Dashing"].redash:
        redashable = false
        can_hurt = true

func hurt(body):
    if dead:
        return
    if body is Player and can_hurt:
        if body.state_machine.current_state == body.state_machine.states["Dashing"]:
            if health == 60.0:
                squid_blood.emitting = true
            else:
                squid_blood.amount *= 2
            dash_post_hurt = true
            iframe_timer.start(IFRAME_TIME)
            can_hurt = false
            if Global.sfx.playing_audios["boss_hurt"].size() < 1:
                Global.sfx.play("boss_hurt", squid_boss.global_position)
            health -= 10
            if health == 30.0 or health <= 0:
                eye_death.emit()
                if health <= 0:
                    dead = true
            else:
                eye_damage.emit()
            squid_boss.squid_body.body.material.set_shader_parameter("blinking", true)
            var tween = self.create_tween()
            tween.tween_method(reduce_blink, 1.0, 0.0, 0.5)
            await tween.finished
            squid_boss.squid_body.body.material.set_shader_parameter("blinking", false)

func reduce_blink(new_val: float) -> void:
    squid_boss.squid_body.body.material.set_shader_parameter("blink_intensity", new_val)

func _on_i_frame_timer_timeout():
    can_hurt = true
