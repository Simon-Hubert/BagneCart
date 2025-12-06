extends Node2D

const MAIN_SCENE_PATH : String = ""

@onready var animation : AnimationPlayer = $CanvasLayer/AnimationPlayer

func _ready() -> void:
	animation.play("Happy")
	
##Restart the game
func _on_restart_button():
	get_tree().change_scene(MAIN_SCENE_PATH)

##Quit the game
func _on_quit_button():
	get_tree().quit()
