class_name quest_manager extends Node

static var Instance : quest_manager = null

@export_category("Graphics")
@export var NPC_graphics_list : Array[Texture2D]

@export_category("Tracery")
@export var quest_tracery_json_path : String = ""
@export var name_input : String = "name"
@export var quest_dialog_input : String = "quest"
@export var quest_finished_input : String = "quest_finished"
@export var quest_not_finished_input : String = "quest_not_finished"
@export var wrong_NPC_input : String = "wrong_NPC"

@export var finishQuest : bool = false #Temporaire, pour le debug

var has_quest : bool = false
var current_quest_giver_name : String = ""

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
	_quest_tracery_grammar.set_save_data("questItem", "#weapon#") #define new quest item
	newData.name = TraceryLoader.getSentenceFromGrammar(_quest_tracery_dictionary, _quest_tracery_grammar, name_input)
	newData.quest_type = 0 #Temporaire, a remplacer par une enum + autres info de quete
	newData.quest_item = TraceryLoader.getSentenceFromGrammar(_quest_tracery_dictionary, _quest_tracery_grammar, "quest_item") #Save quest item into data 
	newData.quest_dialog = TraceryLoader.getSentenceFromGrammar(_quest_tracery_dictionary, _quest_tracery_grammar, quest_dialog_input)
	return newData

##Give a new PNJ sprite from database
func get_random_PNJ_Texture() -> Texture2D:
	var rng = RandomNumberGenerator.new()
	return NPC_graphics_list[rng.randi() % NPC_graphics_list.size()]

##Accpet a quest from an NPC
func accept_new_quest(data : NPC_data) -> void:
	if !has_quest:
		has_quest = true
		current_quest_giver_name = data.name
		_quest_tracery_grammar.set_save_data("questItem", data.quest_item) #get quest item from data
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
	return TraceryLoader.getSentenceFromGrammar(_quest_tracery_dictionary, _quest_tracery_grammar, quest_finished_input)
	
##Get a random line when the quest is finished
func get_wrong_NPC_line() -> String:
	return TraceryLoader.getSentenceFromGrammar(_quest_tracery_dictionary, _quest_tracery_grammar, wrong_NPC_input)

##Get a random line when ask the NPC but quest is not finished	
func get_quest_not_finished_line() -> String:
	return TraceryLoader.getSentenceFromGrammar(_quest_tracery_dictionary, _quest_tracery_grammar, quest_not_finished_input)
