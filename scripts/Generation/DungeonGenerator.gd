class_name DungeonGenerator extends Node

@export var _rooms : Dictionary[String, PackedScene]
@export var ROOMSIZE : int
@export var NumberOfRooms : int


func _ready():
	var dungeon = _generate_dungeon(NumberOfRooms)
	_generate_map(dungeon)
	
func _generate_dungeon(count: int) -> Array[RoomData]:
	var dungeon: Array[RoomData] = []
	var occupied := {}
	var visited := []
	var current_room := RoomData.new()
	current_room.grid_pos = Vector2i.ZERO
	current_room.doors = [true, true, true, true]
	dungeon.append(current_room)
	visited.append(current_room)
	occupied[current_room.grid_pos] = true

	for i in range(1, count):
		var available_dirs = _get_available_dirs_for_room(current_room.doors)
		
		available_dirs = available_dirs.filter(func(direction): return !occupied.has(current_room.grid_pos + direction))

		if available_dirs.is_empty():
			print("Dead end at ", current_room.grid_pos)
			current_room = visited[randi() % visited.size()]
			i -= 1
			continue

		var dir = available_dirs[randi_range(0, available_dirs.size() - 1)]
		
		var next_room = _random_next_room_from_dir(dir)
		next_room.grid_pos = current_room.grid_pos + dir

		var opposite_index = _get_opposite_door_index(dir)
		next_room.doors[opposite_index] = true

		for j in range(4):
			if j != opposite_index and randf() < 0.3:
				next_room.doors[j] = true

		dungeon.append(next_room)
		visited.append(next_room)
		occupied[next_room.grid_pos] = true

		current_room = next_room
		
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
		
func _get_available_dirs_for_room(doors: Array[bool]) -> Array[Vector2i]:
	var dirs : Array[Vector2i] = []
	if(doors[0]):
		dirs.append(Vector2i(0, 1)) #bottom
	if(doors[1]):
		dirs.append(Vector2i(0, -1)) #top
	if(doors[2]):
		dirs.append(Vector2i(-1, 0)) #left
	if(doors[3]):
		dirs.append(Vector2i(1, 0)) #right
	
	return dirs

			
func _get_room_key_from_doors(doors: Array) -> String:
	return "%d%d%d%d" % [ 
		int(doors[0]),
		int(doors[1]),
		int(doors[2]),
		int(doors[3]),]
func _get_room_keys_from_dir(dir: Vector2i) -> Array[String]:
	var valid_keys: Array[String] = []
	
	var required_index := -1
	
	if dir == Vector2i(0, 1):
		required_index = 1
	elif dir == Vector2i(0, -1):
		required_index = 0
	elif dir == Vector2i(-1, 0):
		required_index = 3
	elif dir == Vector2i(1, 0):
		required_index = 2
		
	for key in _rooms.keys():
		if key[required_index] == "1":
			valid_keys.append(key)
	
	return valid_keys
	

func _random_next_room_from_dir(dir: Vector2i) -> RoomData:
	var possible_keys = _get_room_keys_from_dir(dir)
	
	if possible_keys.is_empty():
		print("Aucune salle possible pour la direction ", dir)
		return null
	
	var selected_key = possible_keys[randi_range(0, possible_keys.size() - 1)]
	
	var room := RoomData.new()
	room.doors = [
		selected_key[0] == "1",
		selected_key[1] == "1",
		selected_key[2] == "1",
		selected_key[3] == "1"
	]
	
	return room
func _get_opposite_door_index(dir: Vector2i) -> int:
	if dir == Vector2i(0, 1): return 1 # top
	if dir == Vector2i(0, -1): return 0 # bottom
	if dir == Vector2i(-1, 0): return 3 # right
	if dir == Vector2i(1, 0): return 2 # left
	return -1
