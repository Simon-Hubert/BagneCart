class_name dialog_UI extends Node

static var Instance : dialog_UI = null

const animation_name = "show_hide_dialog"

@onready var quest_arrow_image : TextureRect = $Fullrect/DialogParent/DialogMargin/DialogBackground/Arrow
@onready var quest_item_image : TextureRect = $Fullrect/DialogParent/DialogMargin/DialogBackground/QuestItem
@onready var quest_arrow_animation :AnimationPlayer = $ArrowAnimation

@export var animtion_player : AnimationPlayer
@export var animation_timer : Timer
@export var character_text_label : RichTextLabel
@export var dialog_text_label : RichTextLabel
 
var is_displayed : bool = false

func _ready() -> void:
	if Instance != null:
		push_error("dialog UI instance already exists")
		return
	Instance = self
	quest_arrow_animation.play("arrow")
	
##Display inforamtion and start animation
func display_dialog(character_name : String, dialog : String, display_icon : Texture2D = null):
	character_text_label.text = character_name
	dialog_text_label.text = dialog
	animtion_player.play(animation_name)
	animation_timer.start()
	is_displayed = true
	
	#Setup quest item
	var has_icon = display_icon != null
	quest_item_image.texture = display_icon
	quest_item_image.visible = has_icon
	quest_arrow_image.visible = has_icon
	
##Hide animation when ends
func _on_timer_timeout() -> void:
	animtion_player.play_backwards(animation_name)
	is_displayed = false
