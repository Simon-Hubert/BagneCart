extends Node2D

const MAIN_SCENE_PATH : String = "res://scenes/main_scene (2).tscn"

@export var animation : AnimationPlayer

func _ready() -> void:
	if animation:
		animation.play("Happy")
	
##Restart the game
func _on_restart_button():
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)

##Quit the game
func _on_quit_button():
	get_tree().quit()
