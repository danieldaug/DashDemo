extends Node
class_name StateMachine

@export var init_state: State
@export var states: Dictionary[String, State] = {}
@export var animation_component: AnimationComponentR

var current_state: State

func _ready():
    for state in states:
        states[state].Transitioned.connect(on_transition)
        if states[state] == init_state:
            animation_component.cur_state = state
    if init_state:
        init_state.Enter()
        current_state = init_state

func _process(delta):
    if current_state:
        current_state.Update(delta)

func _physics_process(delta):
    if current_state:
        current_state.Physics_Update(delta)

func on_transition(state, new_state_name):
    # Make coming from correct state
    if state != current_state:
        return
    # Get new state from dictionary
    var new_state = states.get(new_state_name)
    if !new_state:
        return
    
    # Exit current state
    if current_state:
        current_state.Exit()
    
    # Enter new state
    new_state.Enter()
    current_state = new_state
    
    # Change animation component state
    animation_component.cur_state = new_state_name
