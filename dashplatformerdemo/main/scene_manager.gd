extends Node
class_name SceneManager

@onready var tree = get_tree()
var cur_scene: PackedScene = Global.main_menu

func switch_scene(next_scene: PackedScene) -> void:
    # Check if the scene exists
    if not next_scene:
        push_error("SceneManager: Tried to switch to a null scene.")
        return

    # Optionally print current scene for debug
    if tree.current_scene:
        print("Unloading scene:", tree.current_scene.name)

    # Change to the new scene
    tree.change_scene_to_packed(next_scene)
    
    # Ensure proper viewport state
    var viewport = get_viewport()
    viewport.set_global_canvas_transform(Transform2D.IDENTITY)
    viewport.canvas_transform = Transform2D.IDENTITY

    # Wait a frame for the scene to load
    await tree.process_frame
    await tree.process_frame

    # After scene is loaded
    if tree.current_scene:
        print("Now in scene:", tree.current_scene.name)
        cur_scene = next_scene
    else:
        push_error("SceneManager: Scene failed to load.")
