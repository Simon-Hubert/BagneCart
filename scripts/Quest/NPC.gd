class_name NPC extends Node

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite
@onready var quest_indicator : NPC_quest_indicator = $QuestIndicator

@export_category("Reference & Data")
@export var data : NPC_data

@export_category("Graphics")
@export var sprite_list : Array[Texture2D]

var is_quest_finished : bool = false

##Init the data and sprite
func init_NPC() -> void:
	if !quest_manager.Instance:
		push_warning("quest_manager instance is null")
		return
	data = quest_manager.Instance.create_NPC_data()
	sprite.texture = sprite_list[quest_manager.Instance.get_rng().randi() % sprite_list.size()]
	quest_indicator.set_quest_sprite(NPC_quest_indicator.QUEST_STATE.HAS_QUEST)
	
##Event when player interact with NPC
func _on_trigger_area_player_interact() -> void:
	#Don't play if a dialog is already shown
	if dialog_UI.Instance.is_displayed:
		return
	animation_player.play("Talk")
	
	#already finished quest
	if is_quest_finished:
		dialog_UI.Instance.display_dialog(data.name, quest_manager.Instance.get_quest_already_finished_line())
		return
	
	#Give new quest
	if !quest_manager.Instance.has_quest:
		quest_manager.Instance.accept_new_quest(data)
		dialog_UI.Instance.display_dialog(data.name, data.quest_dialog)
		quest_indicator.set_quest_sprite(NPC_quest_indicator.QUEST_STATE.QUEST_ACCEPTED)
		return	
	
	#Can't take two quest at same time
	if quest_manager.Instance.current_quest_giver_name != data.name:
		dialog_UI.Instance.display_dialog(data.name, quest_manager.Instance.get_wrong_NPC_line())
		return
		
	#Check if quest completed
	if quest_manager.Instance.check_validate_quest():
		dialog_UI.Instance.display_dialog(data.name, quest_manager.Instance.get_quest_finished_line())
		is_quest_finished = true
		quest_indicator.set_quest_sprite(NPC_quest_indicator.QUEST_STATE.QUEST_FINISHED)
	else:
		dialog_UI.Instance.display_dialog(data.name, quest_manager.Instance.get_quest_not_finished_line())
