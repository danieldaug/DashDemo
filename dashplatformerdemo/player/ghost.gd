extends Sprite2D

var cur_time: float = 0.0
var increase: float = 0.1

const LIFETIME: float = 0.01

func _process(delta):
    cur_time += increase * delta
    if cur_time >= LIFETIME: 
        queue_free()
