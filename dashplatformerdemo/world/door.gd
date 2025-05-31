extends TileMapLayer

@export var flipped: bool = false
@onready var init_pos: float = global_position.y
var opening: bool = true

const POSITION_LIMIT: float = 192.0
const OPEN_SPEED: float = 20.0

func open():
    opening = true

func _physics_process(delta):
    if opening:
        if flipped:
            global_position.y += OPEN_SPEED * delta
            if global_position.y >= init_pos + POSITION_LIMIT:
                opening = false
        else:
            global_position.y -= OPEN_SPEED * delta
            if global_position.y <= init_pos - POSITION_LIMIT:
                opening = false
