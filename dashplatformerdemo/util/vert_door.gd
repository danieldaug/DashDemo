extends TileMapLayer

@onready var init_pos: float = global_position.y
var closing: bool = false

const POSITION_LIMIT: float = 736.0
const CLOSE_SPEED: float = 100.0

func close():
    closing = true

func _physics_process(delta):
    if closing:
        global_position.y += CLOSE_SPEED * delta
        if global_position.y >= init_pos + POSITION_LIMIT:
            closing = false
