class_name quest_manager extends Node

enum QUEST_TYPE { DELIVER_ITEM, GET_PEOPLE_TO_PLACE }

static var Instance : quest_manager = null

const NPC_SCENE_PATH : String = "res://scenes/Quest/NPC.tscn" 
const NPC_SCENE : PackedScene = preload(NPC_SCENE_PATH)

const QUEST_ITEM_SCENE_PATH : String = "res://scenes/Items/questItem.tscn" 
const QUEST_ITEM_SCENE : PackedScene = preload(QUEST_ITEM_SCENE_PATH)

@export_category("Tracery")
@export_file var quest_tracery_json_path : String = ""
@export var name_symbol : String = "origin"
@export var quest_dialog_symbol : Dictionary[QUEST_TYPE, String]
@export var quest_finished_symbol : Dictionary[QUEST_TYPE, String]
@export var quest_not_finished_symbol : Dictionary[QUEST_TYPE, String]
@export var wrong_NPC_symbol : Dictionary[QUEST_TYPE, String]
@export var quest_already_finished : String = "quest_finished_thank"
@export var quest_item_symbol : Dictionary[QUEST_TYPE, String]

@export_category("Quest")
@export var npc_number : int = 2

var number_quest_completed : int = 0

var has_quest : bool = false
var current_quest_giver_name : String = ""
var current_quest_giver_position : Vector2
var current_quest_type : QUEST_TYPE
var current_quest_item : String = ""
var npc_spawn_point_list : Array[Vector2]

var quest_item_list : Array[quest_item]
var spawned_NPC_position_list : PackedVector2Array
var spawned_quest_item_position_list : PackedVector2Array

var _quest_tracery_dictionary : Dictionary
var _quest_tracery_grammar : Tracery.Grammar

signal on_quest_manager_init
signal on_quest_recieved
signal on_quest_finished
signal on_all_quest_completed

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	if Instance != null:
		push_error("quest_manager instance already exists")
		return
	Instance = self
	#Create dictionary & grammar
	_quest_tracery_dictionary = TraceryLoader.create_grammar_dictionary(quest_tracery_json_path)
	_quest_tracery_grammar = TraceryLoader.create_grammar(_quest_tracery_dictionary)
	on_quest_manager_init.emit()
	
##Give a reference to the random number generator
##Allows for one instance of the rng
func get_rng() -> RandomNumberGenerator:
	rng.randomize()
	return rng

##Spawns NPC's based on the list of positions
func spawn_NPC() -> void:
	if npc_spawn_point_list.size() <= 0:
		push_error("No spawn point added !")
		return
	if npc_spawn_point_list.size() < npc_number * 2:
		push_error("Not enough spawn point for NPC's AND quest items !")
		return
			
	var quest_item_name_list : Array[String]	
	#Spawn NPC
	for i in range(npc_number):
		var newNPC : NPC = NPC_SCENE.instantiate()
		add_child(newNPC)
		var position_index := rng.randi() % npc_spawn_point_list.size()
		newNPC.global_position = npc_spawn_point_list[position_index]
		npc_spawn_point_list.remove_at(position_index)
		newNPC.init_NPC()
		quest_item_name_list.append(newNPC.data.quest_item_to_get)
		spawned_NPC_position_list.append(newNPC.global_position)
		
	#Spawn needed quest item
	for item in quest_item_name_list:
		var newQuestItem : quest_item = QUEST_ITEM_SCENE.instantiate()
		add_child(newQuestItem)
		quest_item_list.append(newQuestItem)
		spawned_quest_item_position_list.append(newQuestItem.global_position)
		#Check if there's still NPC spawners (are reused for quest item spawn)
		var position_index := rng.randi() % npc_spawn_point_list.size()
		newQuestItem.global_position = npc_spawn_point_list[position_index]
		npc_spawn_point_list.remove_at(position_index)
		newQuestItem.init_item(item, rng)
		
##Give info about the quest to a new NPC
func create_NPC_data(suffix : String) -> NPC_data:
	var newData : NPC_data = NPC_data.new()
	newData.name = TraceryLoader.getSentenceFromGrammar(_quest_tracery_dictionary, _quest_tracery_grammar, name_symbol + suffix)
	newData.quest_type = (rng.randi() % quest_manager.QUEST_TYPE.size()) as quest_manager.QUEST_TYPE
	if !quest_item_symbol.has(newData.quest_type):
		push_error("Quest type" + str(newData.quest_type) + "doesn't have any symbol linked")
		
	_quest_tracery_grammar.set_save_data("questItem", quest_item_symbol[newData.quest_type]) #define new quest item & save into data
	newData.quest_item_to_get = TraceryLoader.getSentenceFromGrammar(_quest_tracery_dictionary, _quest_tracery_grammar, "quest_item")
	newData.quest_dialog = TraceryLoader.getSentenceFromGrammar(_quest_tracery_dictionary, _quest_tracery_grammar, quest_dialog_symbol[newData.quest_type] + suffix)
	return newData

##Accept a quest from an NPC
func accept_new_quest(data : NPC_data, NPC_position : Vector2) -> void:
	if !has_quest:
		has_quest = true
		current_quest_giver_name = data.name
		current_quest_giver_position = NPC_position
		_quest_tracery_grammar.set_save_data("questItem", data.quest_item_to_get) #get quest item from data
		current_quest_type = data.quest_type
		current_quest_item = data.quest_item_to_get
		on_quest_recieved.emit()

##Get the nearest item from current accepted quest NPC
func get_nearest_item() -> float:
	var _min_distance : float = -1
	#Check through all items which is correct
	for item in quest_item_list:
		if !item.is_correct_item_name(current_quest_item):
			continue
		var distance_to_item : float = current_quest_giver_position.distance_to(item.global_position)
		if  distance_to_item <= _min_distance || _min_distance == -1:
			_min_distance = distance_to_item
	print(_min_distance)
	return _min_distance

##get current quest item sprite
func get_current_quest_item_sprite() -> Texture2D:
	for item in quest_item_list:
		if item.is_correct_item_name(current_quest_item):
			return item.sprite.texture
	return null

##Look if the current quest is validated
func check_validate_quest() -> bool:
	#Check every item if one of them is valid
	for item in quest_item_list:
		if item.is_correct_item(current_quest_item):
			has_quest = false
			
			#Dismount item from cart
			if item.is_in_cart:
				game_manager.Instance.cart_ref.dismount_item()
				
			#Remove and destroy item 
			quest_item_list.erase(item)
			item.queue_free()
			
			#Check if completed all quest
			number_quest_completed +=1
			if number_quest_completed >= npc_number:
				on_all_quest_completed.emit()
			#else just play regular quest finished
			else:
				on_quest_finished.emit()
			
			return true;
	return false;
	
##Get a random line when the quest is finished
func get_quest_finished_line(suffix : String) -> String:
	return TraceryLoader.getSentenceFromGrammar(_quest_tracery_dictionary, _quest_tracery_grammar, quest_finished_symbol[current_quest_type] + suffix)
	
##Get a random line when the wrong NPC is interacted
func get_wrong_NPC_line(suffix : String) -> String:
	return TraceryLoader.getSentenceFromGrammar(_quest_tracery_dictionary, _quest_tracery_grammar, wrong_NPC_symbol[current_quest_type] + suffix)

##Get a random line when ask the NPC but quest is not finished	
func get_quest_not_finished_line(suffix : String) -> String:
	return TraceryLoader.getSentenceFromGrammar(_quest_tracery_dictionary, _quest_tracery_grammar, quest_not_finished_symbol[current_quest_type] + suffix)

##Get a random line when ask the NPC but quest is already finished
func get_quest_already_finished_line() -> String:
	return TraceryLoader.getSentenceFromGrammar(_quest_tracery_dictionary, _quest_tracery_grammar, quest_already_finished)

##Returns the closest item quest from a specific position
func get_closest_quest_item(player_position : Vector2) -> closest_quest_item_data:
	var cloest_data : closest_quest_item_data = closest_quest_item_data.new()
	for item in quest_item_list:
		if !item.is_correct_item_name(quest_manager.Instance.current_quest_item):
			continue
		if cloest_data.distance == -1 || cloest_data.distance > item.global_position.distance_to(player_position):
			cloest_data.distance = item.global_position.distance_to(player_position)
			cloest_data.position = item.global_position
	return cloest_data

class closest_quest_item_data:
	var position : Vector2
	var distance : float = -1
