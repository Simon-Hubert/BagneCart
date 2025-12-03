class_name quest_manager extends Node

enum QUEST_TYPE { DELIVER_ITEM, GET_PEOPLE_TO_PLACE }

static var Instance : quest_manager = null

@export_category("Tracery")
@export var quest_tracery_json_path : String = ""
@export var name_symbol : String = "origin"
@export var quest_dialog_symbol : Dictionary[QUEST_TYPE, String]
@export var quest_finished_symbol : Dictionary[QUEST_TYPE, String]
@export var quest_not_finished_symbol : Dictionary[QUEST_TYPE, String]
@export var wrong_NPC_symbol : Dictionary[QUEST_TYPE, String]

@export var quest_item_symbol : Dictionary[QUEST_TYPE, String]

@export_category("Quest")
@export var finishQuest : bool = false #Temporaire, pour le debug

var has_quest : bool = false
var current_quest_giver_name : String = ""
var current_quest_type : QUEST_TYPE

var _quest_tracery_dictionary : Dictionary
var _quest_tracery_grammar : Tracery.Grammar
signal on_quest_manager_init
signal on_quest_recieved
signal on_quest_finished

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

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
	newData.name = TraceryLoader.getSentenceFromGrammar(_quest_tracery_dictionary, _quest_tracery_grammar, name_symbol)
	newData.quest_type = (rng.randi() % quest_manager.QUEST_TYPE.size()) as quest_manager.QUEST_TYPE
	print(rng.randi() % quest_manager.QUEST_TYPE.size())
	if !quest_item_symbol.has(newData.quest_type):
		push_error("Quest type" + str(newData.quest_type) + "doesn't have any symbol linked")
		
	_quest_tracery_grammar.set_save_data("questItem", quest_item_symbol[newData.quest_type]) #define new quest item & save into data
	newData.quest_item = TraceryLoader.getSentenceFromGrammar(_quest_tracery_dictionary, _quest_tracery_grammar, "quest_item")
	newData.quest_dialog = TraceryLoader.getSentenceFromGrammar(_quest_tracery_dictionary, _quest_tracery_grammar, quest_dialog_symbol[newData.quest_type])
	return newData

##Accept a quest from an NPC
func accept_new_quest(data : NPC_data) -> void:
	if !has_quest:
		has_quest = true
		current_quest_giver_name = data.name
		_quest_tracery_grammar.set_save_data("questItem", data.quest_item) #get quest item from data
		current_quest_type = data.quest_type
		on_quest_recieved.emit()

##Look if the current quest is validated
func check_validate_quest() -> bool:
	if finishQuest:
		on_quest_finished.emit()
		has_quest = false
		return true;
		
	return false;
	
##Get a random line when the wrong NPC is interacted
func get_quest_finished_line() -> String:
	return TraceryLoader.getSentenceFromGrammar(_quest_tracery_dictionary, _quest_tracery_grammar, quest_finished_symbol[current_quest_type])
	
##Get a random line when the quest is finished
func get_wrong_NPC_line() -> String:
	return TraceryLoader.getSentenceFromGrammar(_quest_tracery_dictionary, _quest_tracery_grammar, wrong_NPC_symbol[current_quest_type])

##Get a random line when ask the NPC but quest is not finished	
func get_quest_not_finished_line() -> String:
	return TraceryLoader.getSentenceFromGrammar(_quest_tracery_dictionary, _quest_tracery_grammar, quest_not_finished_symbol[current_quest_type])
