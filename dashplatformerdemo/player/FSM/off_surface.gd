extends State
class_name OffSurface

@export var player: Player

var bouncing: bool = false

# Constants
const GRAVITY: float = 250.0
const GRAVITY_MAGNITUDE: float = 11

func dash_input():
    var input_vector = Vector2(
        Input.get_action_strength("right") - Input.get_action_strength("left"),
        Input.get_action_strength("down") - Input.get_action_strength("up")
    )

    player.dash_aim = input_vector.normalized() if input_vector.length() > 0 else Vector2.ZERO
    
    if player.dash_aim != Vector2.ZERO and Input.is_action_just_pressed("dash") and player.dash_cooldown.is_stopped():
        Global.sfx.play("dash")
        Transitioned.emit(self, "Dashing")

func Physics_Update(delta: float):
    # Possible dash state change
    dash_input()
    
    # Jump and gravity logic
    if !bouncing:
        if Input.is_action_just_released("jump") and player.velocity.y < 0:
            player.velocity.y = 0
        if player.velocity.y < 0:
            player.velocity.y += GRAVITY * delta * GRAVITY_MAGNITUDE
        else:
            player.velocity.y += GRAVITY * delta
    player.move_and_slide()
    if player.get_slide_collision_count() > 0:
        Transitioned.emit(self, "OnSurface")

func Exit():
    player.bouncing = false
    bouncing = false
