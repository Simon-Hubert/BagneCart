class_name dialog_UI extends Node

static var Instance : dialog_UI = null

const ANIMATION_NAME = "show_hide_dialog"
const DIALOG_SOUND_FILE : AudioStream = preload("res://Audio/Dialogue.mp3")

@onready var quest_arrow_image : TextureRect = $Fullrect/DialogParent/DialogMargin/DialogBackground/Arrow
@onready var quest_item_image : TextureRect = $Fullrect/DialogParent/DialogMargin/DialogBackground/QuestItem
@onready var quest_arrow_animation :AnimationPlayer = $ArrowAnimation
@onready var _sound_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var _bind_timer : Timer = $Timer

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
	animtion_player.play(ANIMATION_NAME)
	if animation_timer:
		animation_timer.start()
	is_displayed = true
	
	#Setup quest item
	var has_icon = display_icon != null
	quest_item_image.texture = display_icon
	quest_item_image.visible = has_icon
	quest_arrow_image.visible = has_icon
	
	#play sound
	_play_sound(DIALOG_SOUND_FILE)
	_bind_timer.start()
	
##Bind to player interact key
func bind_close_dialog() -> void:
	game_manager.Instance.player_ref.on_player_interacted.connect(close_dialog)
	
##Hide animation when ends
func close_dialog() -> void:
	game_manager.Instance.player_ref.on_player_interacted.disconnect(close_dialog)
	animtion_player.play_backwards(ANIMATION_NAME)
	is_displayed = false
	_sound_player.stop()
	
	
##Load and play a specfic sound
func _play_sound(sound : AudioStream):
	_sound_player.stream = sound
	_sound_player.play()
