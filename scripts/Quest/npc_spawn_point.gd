class_name npc_spawn_point extends Node2D

func _ready():
	#Add position to the list of possible npc spawn positions
	if !quest_manager.Instance:
		push_warning("quest manager isn't ready yet !")
		return
	quest_manager.Instance.npc_spawn_point_list.append(global_position)
