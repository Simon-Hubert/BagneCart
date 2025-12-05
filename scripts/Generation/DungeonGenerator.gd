class_name DungeonGenerator extends Node

@export var _rooms : Dictionary[String, PackedScene]
@export var ROOMSIZE : int
@export var NumberOfRooms : int
@export var extra_doors_probability : float


func _ready():
	var result = _generate_dungeon(NumberOfRooms)
	var dungeon = result.dungeon
	var occupied = result.occupied
	_fix_doors(dungeon, occupied)
	_generate_map(dungeon)
	
func _generate_dungeon(count: int) -> Dictionary:
	#var countRoomsInstantiated = 0
	var dungeon: Array[RoomData] = []
	var occupied := {}
	var visited := []
	var current_room := RoomData.new()
	current_room.grid_pos = Vector2i.ZERO
	current_room.doors = [true, true, true, true]
	dungeon.append(current_room)
	visited.append(current_room)
	occupied[current_room.grid_pos] = true

	var stack : Array[RoomData] = []
	stack.append(current_room)

	for i in range(1, count):
		var available_dirs = _get_available_dirs_for_room(current_room, occupied)

		while available_dirs.is_empty():
			print("Dead end at ", current_room.grid_pos)

			stack.pop_back()

			if stack.is_empty():
				push_error("Plus aucune salle pour backtrack génération impossible.")
				return {"dungeon": dungeon, "occupied": occupied}

			current_room = stack.back()
			available_dirs = _get_available_dirs_for_room(current_room, occupied)

		var dir = available_dirs[randi_range(0, available_dirs.size() - 1)]

		var next_room = _random_next_room_from_dir(dir)
		next_room.grid_pos = current_room.grid_pos + dir

		var next_index = _get_opposite_door_index(dir)
		var cur_index = _get_opposite_door_index(-dir)

		current_room.doors[cur_index] = true
		next_room.doors[next_index] = true

		for j in range(4):
			if j != next_index and randf() < extra_doors_probability / 100:
				next_room.doors[j] = true

		dungeon.append(next_room)
		visited.append(next_room)
		occupied[next_room.grid_pos] = true

		current_room = next_room
		stack.append(current_room)
		
	return {"dungeon": dungeon, "occupied": occupied}

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
	
	quest_manager.Instance.spawn_NPC()
		
func _get_available_dirs_for_room(room: RoomData, occupied: Dictionary) -> Array[Vector2i]:
	var dirs: Array[Vector2i] = []
	var possible = [
		Vector2i(0, 1),
		Vector2i(0, -1),
		Vector2i(-1, 0),
		Vector2i(1, 0)
	]

	for dir in possible:
		if !occupied.has(room.grid_pos + dir):
			dirs.append(dir)

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

func _fix_doors(dungeon: Array[RoomData], occupied: Dictionary):
	for room in dungeon:
		var pos = room.grid_pos

		var neighbors = {
			0: Vector2i(0, 1),   # bottom
			1: Vector2i(0, -1),  # top
			2: Vector2i(-1, 0),  # left
			3: Vector2i(1, 0)    # right
		}

		for door_index in neighbors.keys():
			var dir = neighbors[door_index]
			var neighbor_pos = pos + dir

			if !occupied.has(neighbor_pos):
				room.doors[door_index] = false
				continue

			var neighbor : RoomData = null
			for r in dungeon:
				if r.grid_pos == neighbor_pos:
					neighbor = r
					break

			if neighbor == null:
				room.doors[door_index] = false
				continue

			var opposite = _get_opposite_door_index(dir)

			if !neighbor.doors[opposite]:
				room.doors[door_index] = false
