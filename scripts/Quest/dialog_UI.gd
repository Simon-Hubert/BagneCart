class_name dialog_UI extends Node

const animation_name = "show_hide_dialog"

@export var animtion_player : AnimationPlayer
@export var animation_timer : Timer
@export var character_text_label : RichTextLabel
@export var dialog_text_label : RichTextLabel
 
##Display inforamtion and show animation
func display_dialog(character_name : String, dialog : String):
	character_text_label.text = character_name
	dialog_text_label.text = dialog
	animtion_player.play(animation_name)
	animation_timer.start()

##Hide animation when ends
func _on_timer_timeout() -> void:
	animtion_player.play(animation_name, -1, -1)
