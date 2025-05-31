extends State
class_name OnSurface

@export var player: Player
@export var coyote_timer: Timer
@export var surface_type: SurfaceType = SurfaceType.FLOOR

enum SurfaceType {
    FLOOR,
    WALL,
    CEILING,
    CEILINGWALL,
    FLOORWALL,
    NONE
}

var wall_left: bool = false
var wall_push: bool = false
var cur_vert_speed: float = 0.0
var exited_multi: bool = false
var disconnected: bool = false
var jumped: bool = false

# Constants
const COYOTE_TIME: float = 0.15
const MAX_SPEED_Y: float = 600.0
const ACCEL_Y: float = 700.0
const JUMP_FORCE: float = 600.0

func wall_physics(delta):
    var cur_pos = player.global_position.x
    # Cancel inputs
    if Input.is_action_just_pressed("jump"):
        surface_type = SurfaceType.NONE
        player.velocity.y = -JUMP_FORCE
        disconnected = true
        jumped = true
        return
    if wall_left and surface_type == SurfaceType.WALL:
        if Input.is_action_just_pressed("right"):
            surface_type = SurfaceType.NONE
            disconnected = true
            return
    elif surface_type == SurfaceType.WALL:
        if Input.is_action_just_pressed("left"):
            surface_type = SurfaceType.NONE
            disconnected = true
            return
    player.velocity.x = -5 if wall_left else 5
    player.cur_speed = clamp(player.cur_speed, -5, 5)
    
    # Conditional vertical movement
    if Input.is_action_pressed("up"):
        if cur_vert_speed > 0:
            cur_vert_speed = 0
        cur_vert_speed = move_toward(cur_vert_speed, -MAX_SPEED_Y, ACCEL_Y * delta)
    elif Input.is_action_pressed("down"):
        if cur_vert_speed < 0: 
            cur_vert_speed = 0
        cur_vert_speed = move_toward(cur_vert_speed, MAX_SPEED_Y, ACCEL_Y * delta)
    else:
        cur_vert_speed = move_toward(cur_vert_speed, 0, ACCEL_Y * 5 * delta)
    player.velocity.y = cur_vert_speed
    
    player.move_and_slide()
    if player.global_position.x < cur_pos and wall_left or player.global_position.x > cur_pos and !wall_left:
        if cur_vert_speed < 0:
            if wall_left:
                player.cur_speed = -100
            else:
                player.cur_speed = 100
        # In case upward velocity needs damping post lauch
        #if cur_vert_speed > (-MAX_SPEED_Y / 1.5) and !jumped:
            #player.velocity.y = cur_vert_speed / 1.75
        surface_type = SurfaceType.NONE

func floor_physics():
    # Cancel inputs
    if Input.is_action_just_pressed("jump"):
        surface_type = SurfaceType.NONE
        player.velocity.y = -JUMP_FORCE
        disconnected = true
        jumped = true
        return
    player.velocity.y = 0
    
    player.move_and_slide()
    if player.get_slide_collision_count() == 0:
        surface_type = SurfaceType.NONE

func ceiling_physics():
    # Cancel inputs
    if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("down"):
        surface_type = SurfaceType.NONE
        disconnected = true
        jumped = true
        player.velocity.y += JUMP_FORCE / 5
        return
    player.velocity.y = 0
    
    player.move_and_slide()
    if player.get_slide_collision_count() == 0:
        surface_type = SurfaceType.NONE

func floor_wall_physics() -> bool:
    # Cancel/transition inputs
    if Input.is_action_just_pressed("jump") and surface_type == SurfaceType.FLOORWALL:
        surface_type = SurfaceType.NONE
        player.velocity.y = -JUMP_FORCE
        disconnected = true
        jumped = true
        return true
    if wall_left and surface_type == SurfaceType.FLOORWALL:
        if Input.is_action_just_pressed("right"):
            surface_type = SurfaceType.FLOOR
            return true
    elif surface_type == SurfaceType.FLOORWALL:
        if Input.is_action_just_pressed("left"):
            surface_type = SurfaceType.FLOOR
            return true
    player.velocity.x = 0
    if Input.is_action_pressed("up") or Input.is_action_pressed("jump"):
        surface_type = SurfaceType.WALL
        return true
    return false

func ceiling_wall_physics() -> bool:
    # Cancel/transition inputs
    if Input.is_action_just_pressed("jump") and surface_type == SurfaceType.FLOORWALL:
        surface_type = SurfaceType.NONE
        disconnected = true
        player.velocity.y = 5
        return true
    if wall_left and surface_type == SurfaceType.CEILINGWALL:
        if Input.is_action_just_pressed("right"):
            surface_type = SurfaceType.CEILING
            return true
    elif surface_type == SurfaceType.CEILINGWALL:
        if Input.is_action_just_pressed("left"):
            surface_type = SurfaceType.CEILING
            return true
    player.velocity.x = int(wall_left) * -5
    if Input.is_action_pressed("down"):
        surface_type = SurfaceType.WALL
        return true
    return false

func multiple_surfaces() -> bool:
    # Check for wall first, wall is a necessary condition
    if surface_type == SurfaceType.WALL:
        # Ceiling to wall
        if player.is_on_ceiling() and !Input.is_action_pressed("down"):
            surface_type = SurfaceType.CEILINGWALL
        # Floor to wall
        elif player.is_on_floor() and !(Input.is_action_pressed("up") or Input.is_action_pressed("jump")):
            surface_type = SurfaceType.FLOORWALL
    return surface_type == SurfaceType.CEILINGWALL or surface_type == SurfaceType.FLOORWALL

func none_physics(): 
    if surface_type == SurfaceType.NONE:
        if (Input.is_action_just_released("jump") and player.velocity.y < 0) or (Input.is_action_just_released("up") and !jumped):
            player.velocity.y = 0
        if !jumped and Input.is_action_just_pressed("jump"):
                player.velocity.y = -JUMP_FORCE
        cur_vert_speed = 0
        player.move_and_slide()

func surface_checks():
    if !(surface_type == SurfaceType.CEILINGWALL or surface_type == SurfaceType.FLOORWALL) and !exited_multi and !disconnected:
        if player.is_on_wall():
            surface_type = SurfaceType.WALL
            for i in range(player.get_slide_collision_count()):
                var collision = player.get_slide_collision(i)
                var normal = collision.get_normal()

                # Check for wall (horizontal collision)
                if abs(normal.x) > 0.9:
                    if normal.x > 0:
                        wall_left = true
                    elif normal.x < 0:
                        wall_left = false

        elif player.is_on_ceiling() and surface_type == SurfaceType.NONE:
            surface_type = SurfaceType.CEILING
            cur_vert_speed = 0
        elif player.is_on_floor() and surface_type == SurfaceType.NONE:
            surface_type = SurfaceType.FLOOR
            cur_vert_speed = 0
    # Turn off any preventative surface check conditionals
    elif exited_multi:
        exited_multi = false
    elif disconnected:
        disconnected = false
    
func dash_input():
    var input_vector = Vector2(
        Input.get_action_strength("right") - Input.get_action_strength("left"),
        Input.get_action_strength("down") - Input.get_action_strength("up")
    )

    player.dash_aim = input_vector.normalized() if input_vector.length() > 0 else Vector2.ZERO
    
    if player.dash_aim != Vector2.ZERO and Input.is_action_just_pressed("dash") and player.dash_cooldown.is_stopped():
        Transitioned.emit(self, "Dashing")

func Physics_Update(delta: float):
    # Possible dash state change
    dash_input()
    
    if multiple_surfaces():
        jumped = false
        if surface_type == SurfaceType.CEILINGWALL:
            exited_multi = ceiling_wall_physics()
        elif surface_type == SurfaceType.FLOORWALL:
            exited_multi = floor_wall_physics()
    elif surface_type == SurfaceType.CEILING:
        jumped = false
        ceiling_physics()
    elif surface_type == SurfaceType.WALL:
        jumped = false
        wall_physics(delta)
    elif surface_type == SurfaceType.FLOOR:
        jumped = false
        floor_physics()
    else:
        none_physics()
    
    # Check for new surface collisions
    surface_checks()
    
    # Transition if coyote timer stopped
    if surface_type != SurfaceType.NONE:
        if surface_type == SurfaceType.WALL or surface_type == SurfaceType.CEILINGWALL or surface_type == SurfaceType.CEILING:
            coyote_timer.start(COYOTE_TIME * 2) 
        else:
            coyote_timer.start(COYOTE_TIME)
    if coyote_timer.is_stopped():
        Transitioned.emit(self, "OffSurface")

func Exit():
    cur_vert_speed = 0.0
    exited_multi = false
    disconnected = false
    jumped = false
