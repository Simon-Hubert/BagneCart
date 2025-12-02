class_name DungeonGenerator extends Node

@export var _rooms : Dictionary[String, PackedScene]
@export var ROOMSIZE : int


func _ready():
	var dungeon = _generate_dungeon(10)
	_generate_map(dungeon)
	
func _generate_dungeon(count: int) -> Array[RoomData]:
	var dungeon: Array[RoomData] = []
	var occupied := {}
	var current_pos := Vector2i.ZERO

	var available_keys: Array[String] = _rooms.keys()

	for i in range(count):
		var room := RoomData.new()
		room.grid_pos = current_pos
		dungeon.append(room)
		occupied[current_pos] = room

		if i < count - 1:
			var possible_dirs := []

			for dir in 4:
				var offset = Vector2i.ZERO
				match dir:
					0: offset = Vector2i(0, -1)
					1: offset = Vector2i(0, 1)
					2: offset = Vector2i(-1, 0)
					3: offset = Vector2i(1, 0)
					_: offset = Vector2i.ZERO

				var new_pos = current_pos + offset
				if occupied.has(new_pos):
					continue

				var key_current_ok := false
				for key in available_keys:
					if key[dir] == "1":
						key_current_ok = true
						break

				var opposite_dir = (dir + 1) if dir % 2 == 0 else (dir - 1)

				var key_next_ok := false
				for key in available_keys:
					if key[opposite_dir] == "1":
						key_next_ok = true
						break

				if key_current_ok and key_next_ok:
					possible_dirs.append(dir)

			if possible_dirs.is_empty():
				print("⚠️ Plus aucune direction possible, fin du donjon.")
				return dungeon

			var chosen_dir = possible_dirs.pick_random()

			room.add_door(chosen_dir)

			var next_room := RoomData.new()
			var offset = Vector2i.ZERO
			match chosen_dir:
				0: offset = Vector2i(0, -1)
				1: offset = Vector2i(0, 1)
				2: offset = Vector2i(-1, 0)
				3: offset = Vector2i(1, 0)
				_: offset = Vector2i.ZERO

			var next_pos = current_pos + offset
			next_room.grid_pos = next_pos

			var opposite = (chosen_dir + 1) if chosen_dir % 2 == 0 else (chosen_dir - 1)
			next_room.add_door(opposite)

			dungeon.append(next_room)
			occupied[next_pos] = next_room
			current_pos = next_pos

	return dungeon

func _generate_map(dungeon: Array[RoomData]):
	for room in dungeon:
		var key = _get_room_key_from_doors(room.doors)
		var packed: PackedScene = _rooms.get(key)
		
		if packed == null:
			print("No room scene for key: %s" % key)
			continue
			

		var instance = packed.instantiate()
		instance.position = room.grid_pos * ROOMSIZE
		add_child(instance)	
		print("Valide room scene for key: %s" % key)
		
			
func _get_room_key_from_doors(doors: Array) -> String:
	return "%d%d%d%d" % [ 
		int(doors[0]),
		int(doors[1]),
		int(doors[2]),
		int(doors[3]),]
	
