extends Node
class_name SquidHealth
@export var squid_boss: SquidBoss

signal eye_damage(is_right)
signal eye_death(is_right)

@export var is_right: bool = true
var health: float = 50.0

func hurt(body):
    if body is Player:
        if body.state_machine.current_state == body.state_machine.states["Dashing"]:
            health -= 10
            if health <= 0:
                eye_death.emit(is_right)
            else:
                eye_damage.emit(is_right)
            var tween = self.create_tween()
            tween.tween_method(reduce_blink, 1.0, 0.0, 0.5)

func reduce_blink(new_val: float) -> void:
    squid_boss.squid_body.body.material.set_shader_parameter("blink_intensity", new_val)
