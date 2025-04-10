extends Node
class_name MovementComponent

@export var player: Player
@export var coyote_timer: Timer
@export var wall_jump_timer: Timer

var bouncing: bool = false

# Speed
var cur_speed: float = 0.0
var cur_jump_speed: float = 0.0
var jumping: bool = false
var falling: bool = false

# Surface conditionals
var on_wall: bool = false
var on_ceiling: bool = false
var wall_pos: float = 0.0
var wall_left: bool = false
var wall_jumping: bool = false
var ceiling_pos: float = 0.0
var moving_right: bool = false
var in_jelly: bool = false

# Constants
const ACCEL_X: float = 600.0
const MAX_SPEED_X: float = 500.0
const ACCEL_Y: float = 700.0
const MAX_SPEED_Y: float = 600.0
const MAX_SPEED_Y_WALK: float = 400.0
const JUMP_FORCE: float = 600.0
const GRAVITY: float = 25.0
const COYOTE_TIME: float = 0.2
const WALL_JUMP_WAIT: float = 0.1

func _physics_process(delta):
    if bouncing:
        player.dashing = false
        player.dash_component.dashing = false
        player.dash_component.can_dash = true
        player.dash_component.dash_particles.emitting = false
        player.move_and_slide()
        _surface_status()
        return
    if player.dashing:
        return 
    _surface_status()
    if in_jelly and !on_wall and !on_ceiling and !player.is_on_floor():
        player.move_and_slide()
        return
    _horizontal_movement(delta)
    _jump(delta)
    _vertical_movement(delta)
    _surface_physics(delta)
    player.velocity.x = clamp(player.velocity.x, -MAX_SPEED_X, MAX_SPEED_X)
    if jumping and !on_wall:
        player.velocity.y = clamp(player.velocity.y, -MAX_SPEED_Y, MAX_SPEED_Y)
    else:
        player.velocity.y = clamp(player.velocity.y, -MAX_SPEED_Y_WALK, MAX_SPEED_Y_WALK)
    player.move_and_slide()

# Jump with coyote timer and wall jump handling
func _jump(delta):
    if Input.is_action_just_pressed("jump") and !coyote_timer.is_stopped():
        # Drop from ceiling
        if on_ceiling:
            player.position.y += 5
            falling = true
        else:
            # Prevent wall stick on wall jump
            if on_wall:
                wall_jumping = true
                wall_jump_timer.start(WALL_JUMP_WAIT)
            if in_jelly:
                player.velocity.y = -JUMP_FORCE / 2
            else:
                player.velocity.y = -JUMP_FORCE
            jumping = true
            falling = false
    elif Input.is_action_just_released("jump") and player.velocity.y < 0:
        player.velocity.y = 0.0
        falling = true
    elif player.is_on_floor() or on_ceiling:
        jumping = false
        falling = false
    elif jumping and player.velocity.y > 0:
        falling = true
        jumping = false

# Input handling for horizontal plane
func _horizontal_movement(delta):
    if Input.is_action_pressed("left"):
        if cur_speed > 0: 
            cur_speed = 0
        cur_speed = move_toward(cur_speed, -MAX_SPEED_X, ACCEL_X * delta)
        moving_right = false
    elif Input.is_action_pressed("right"):
        if cur_speed < 0: 
            cur_speed = 0
        cur_speed = move_toward(cur_speed, MAX_SPEED_X, ACCEL_X * delta)
        moving_right = true
    else:
        cur_speed = move_toward(cur_speed, 0, ACCEL_X * 5 * delta)
    player.velocity.x = cur_speed
    
    wall_left = !moving_right

# Input handling for vertical plane
func _vertical_movement(delta):
    # Only take input when moving along wall
    if !jumping and on_wall:
        if Input.is_action_pressed("up"):
            if cur_jump_speed > 0: 
                cur_jump_speed = 0
            cur_jump_speed = move_toward(cur_jump_speed, -MAX_SPEED_Y, ACCEL_Y * delta)
        elif Input.is_action_pressed("down"):
            if cur_jump_speed < 0: 
                cur_jump_speed = 0
            cur_jump_speed = move_toward(cur_jump_speed, MAX_SPEED_Y, ACCEL_Y * delta)
        else:
            cur_jump_speed = move_toward(cur_jump_speed, 0, ACCEL_Y * 5 * delta)
        player.velocity.y = cur_jump_speed

# Boolean setter for surface contact status
func _surface_status():
    # Booleans for wall contact
    if player.is_on_wall() and !wall_jumping:
        wall_pos = player.global_position.x
        player.velocity.x = 0
        jumping = false
        falling = false
        on_wall = true
        bouncing = false
        
    # Detach from wall
    if on_wall and abs(player.global_position.x - wall_pos) > 5:
        on_wall = false
        if player.velocity.y >= 0:
            falling = true
    
    # Booleans for ceiling contact
    if player.is_on_ceiling():
        ceiling_pos = player.global_position.y
        player.velocity.y = 0
        jumping = false
        falling = false
        on_ceiling = true
        bouncing = false
        
    # Detach from ceiling
    if on_ceiling and player.global_position.y != ceiling_pos:
        on_ceiling = false
        falling = true
    
    if !on_wall and !on_ceiling and !player.is_on_floor() and player.velocity.y > 0:
        falling = true
    
    if player.is_on_floor():
        bouncing = false

# Physics applied based on current surface
func _surface_physics(delta):
    # Set gravity based on surface
    if on_ceiling:
        player.velocity.y -= GRAVITY
        coyote_timer.start(COYOTE_TIME)
    elif on_wall:
        if !jumping:
            coyote_timer.start(COYOTE_TIME)
            if wall_left:
                player.velocity.x -= GRAVITY
            else:
                player.velocity.x += GRAVITY
        else:
            player.velocity.y += GRAVITY
    elif !player.is_on_floor():
        if falling:
            player.velocity.y += GRAVITY / 4
        else:
            player.velocity.y += GRAVITY
    else:
        coyote_timer.start(COYOTE_TIME)

func _on_wall_jump_timer_timeout():
    wall_jumping = false
