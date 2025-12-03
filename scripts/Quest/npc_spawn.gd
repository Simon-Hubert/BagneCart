class_name npc_spawn extends Node2D

const NPC_SCENE_PATH : String = "res://scenes/quest/NPC.tscn" 
const NPC_SCENE : PackedScene = preload(NPC_SCENE_PATH)

func spawn_npc():
	var newNPC : NPC = NPC_SCENE.instantiate()
	newNPC.init_NPC()
	queue_free()
