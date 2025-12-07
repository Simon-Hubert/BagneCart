class_name RoomData extends Node2D

@export var room_infos : RoomInfos
#var CurrentNeighboors : Dictionary[String, Room]
var doors : Array[bool] = [false, false, false, false]
var grid_pos : Vector2i = Vector2i.ZERO

func add_door(dir: int):
	doors[dir] = true
