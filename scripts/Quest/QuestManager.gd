class_name QuestManager extends Node

static var Instance : QuestManager = null

@export var quest_tracery_json_path : String = ""
@export var nameInput : String = "name"
@export var questDialogInput : String = "quest"

@export var finishQuest : bool = false #Temporaire, pour le debug

var has_quest : bool = false

var _quest_tracery_dictionary : Dictionary
var _quest_tracery_grammar : Tracery.Grammar

signal on_quest_manager_init
signal on_quest_recieved
signal on_quest_finished

func _ready() -> void:
	if Instance != null:
		push_error("QuestManager instance already exists")
		return
	Instance = self
	#Create dictionary & grammar
	_quest_tracery_dictionary = TraceryLoader.create_grammar_dictionary(quest_tracery_json_path)
	_quest_tracery_grammar = TraceryLoader.create_grammar(_quest_tracery_dictionary)
	on_quest_manager_init.emit()
	
##Give info about the quest to a new NPC
func create_NPC_data() -> NPC_data:
	var newData : NPC_data = NPC_data.new()
	newData.name = TraceryLoader.getSentenceFromGrammar(_quest_tracery_dictionary, _quest_tracery_grammar, nameInput)
	newData.quest_type = 0 #Temporaire, a remplacer par une enum + autres info de quete
	newData.quest_dialog = TraceryLoader.getSentenceFromGrammar(_quest_tracery_dictionary, _quest_tracery_grammar, questDialogInput)
	return newData

##Accpet a quest from an NPC
func accept_new_quest(_data : NPC_data) -> void:
	if !has_quest:
		has_quest = true
		on_quest_recieved.emit()

##Look if the current quest is validated
func check_validate_quest() -> bool:
	if finishQuest:
		on_quest_finished.emit()
		has_quest = false
		return true;
		
	return false;
