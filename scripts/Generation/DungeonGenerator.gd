class_name DungeonGenerator extends Node2D
enum RoomType
{
	NO,
	BI,
	UNI,
	TRI,
	MULTI
}
@export var _rail : PackedScene
@export var _switch : PackedScene
@export var _lever : PackedScene
@export var _rooms : Dictionary[String, PackedScene]
@export var ROOMSIZE : Vector2
@export var RAILSIZE : int
@export var NumberOfRooms : int
@export var bi_directional_weight : float
@export var tri_directional_weight : float
@export var multi_directional_weight : float
@export var uni_directional_weight : float
@export var no_direction_weight : float

@export_category("Spawn lever")
@export var lever_distance_to_switch : float = 25

var _first_rail : Rail


func _ready():
	var result = _generate_dungeon(NumberOfRooms)
	var dungeon = result.dungeon
	var occupied = result.occupied
	_fix_doors(dungeon, occupied)
	_generate_map(dungeon)
	
	#Setup UI (TODO Remove await & fix setup order)
	await get_tree().create_timer(0.1).timeout
	game_manager.Instance.on_setup_UI.emit()
	
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
		var counter = 0
		while available_dirs.is_empty():
			if counter > 100000:
				return _generate_dungeon(count)
			counter += 1

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
		next_room.from_dir = - dir

		var next_index = _get_opposite_door_index_from_dir(dir)
		var cur_index = _get_opposite_door_index_from_dir(-dir)

		current_room.doors[cur_index] = true
		next_room.doors[next_index] = true

		dungeon.append(next_room)
		visited.append(next_room)
		occupied[next_room.grid_pos] = true

		current_room = next_room
		stack.append(current_room)
		
	return {"dungeon": dungeon, "occupied": occupied}

func _generate_map(dungeon: Array[RoomData]):
	var previous_room : RoomData = null
	var rooms : Dictionary[Vector2, RoomData]
	for room in dungeon:
		var key = _get_room_key_from_doors(room.doors)
		var packed: PackedScene = _rooms.get(key)
		
		if packed == null:
			print("No room scene for key: %s" % key)
			continue

		var instance = packed.instantiate()
		instance.position = Vector2(room.grid_pos.x * ROOMSIZE.x, room.grid_pos.y * ROOMSIZE.y)
		rooms[Vector2(instance.global_position.x + ROOMSIZE.x / 2, instance.global_position.y - ROOMSIZE.y / 2)] = room
		add_child(instance)	
		
		#spawn player & cam (if first room)
		if !previous_room:
			var spawn_position : Vector2 = instance.position
			spawn_position.x += ROOMSIZE.x * .5
			spawn_position.y -= ROOMSIZE.y * .5
			game_manager.Instance.spawn_player_and_camera(spawn_position)	
			
		generate_rails_for_room(instance, room, !previous_room, rooms)
		previous_room = room
		print("Valide room scene for key: %s" % key)

	RailManager.instance.on_start()	
	_first_rail.propagate_orientation(_first_rail.dir)
	#Spawn NPC & quest item
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
		
	valid_keys = _compute_keys(required_index)
	
	return valid_keys
	
func _compute_keys(required_index : int) -> Array[String]:
	var valid_keys: Array[String] = []
	var weights : Dictionary = {
		RoomType.NO: no_direction_weight,
		RoomType.UNI: uni_directional_weight,
		RoomType.BI: bi_directional_weight,
		RoomType.TRI: tri_directional_weight,
		RoomType.MULTI: multi_directional_weight
	}
	
	var total_weight : float = 0.0
	for weight in weights.values():
		total_weight += weight	
		
	if total_weight <= 0:
		return _generate_all_valid_keys(required_index)
		
	var rng = randf() * total_weight
	
	var cumulative_weight : float = 0.0
	var selected_room_type : RoomType = RoomType.NO
	
	for type_key in weights.keys():
		cumulative_weight += weights[type_key]
		if rng < cumulative_weight:
			selected_room_type = type_key
			break

	valid_keys = _generate_keys_for_type(selected_room_type, required_index)
	
	return valid_keys
func _generate_keys_for_type(room_type : RoomType, required_index : int) -> Array[String]:
	var keys: Array[String] = []
	
	match room_type:
		RoomType.NO:
			keys.append("0001")
			keys.append("0010")
			keys.append("0100")
			keys.append("1000")
		RoomType.BI:
			keys.append("1001")
			keys.append("1010")
			keys.append("0101")
			keys.append("0110")
		RoomType.UNI:
			keys.append("1100")
			keys.append("0011")
		RoomType.TRI:
			keys.append("1110")
			keys.append("1101")
			keys.append("1110")
			keys.append("1101")
		RoomType.MULTI:
			keys.append("1111")
			
	for key in keys:
		if key[required_index] == "0":
			keys.erase(key)
			
	return keys
func _generate_all_valid_keys(required_index) -> Array[String]:
	var keys: Array[String] = []
	for key in _rooms.keys():
		if key[required_index] == "1":
			keys.append(key)
			
	return keys
	
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
	
func _get_door_index_from_dir(dir: Vector2i) -> int:
	if dir == Vector2i(0, -1): return 1 # top
	if dir == Vector2i(0, 1): return 0 # bottom
	if dir == Vector2i(1, 0): return 3 # right
	if dir == Vector2i(-1, 0): return 2 # left
	return -1
func _get_opposite_door_index_from_dir(dir: Vector2i) -> int:
	if dir == Vector2i(0, 1): return 1 # top
	if dir == Vector2i(0, -1): return 0 # bottom
	if dir == Vector2i(-1, 0): return 3 # right
	if dir == Vector2i(1, 0): return 2 # left
	return -1

func _get_opposite_door_index(index : int) -> int:
	if index == 0: return 1 # top
	if index == 1: return 0 # bottom
	if index == 2: return 3 # right
	if index == 3: return 2 # left
	return -1

func _fix_doors(dungeon: Array[RoomData], _occupied: Dictionary):
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

			#if !occupied.has(neighbor_pos):
				#room.doors[door_index] = false
				#continue

			var neighbor : RoomData = null
			for r in dungeon:
				if r.grid_pos == neighbor_pos:
					neighbor = r
					break

			if neighbor == null:
				room.doors[door_index] = false
				continue

			var opposite = _get_opposite_door_index_from_dir(dir)

			if !neighbor.doors[opposite]:
				room.doors[door_index] = false

func generate_rails_for_room(inst : Node, room : RoomData, spawn_cart : bool, rooms : Dictionary[Vector2, RoomData]):
	
	var roomCenter = Vector2(inst.global_position.x + ROOMSIZE.x / 2.0, inst.global_position.y - ROOMSIZE.y / 2.0)
	var possible = [
		Vector2i(0, 1),
		Vector2i(0, -1),
		Vector2i(-1, 0),
		Vector2i(1, 0)
	]
	var count = 0
	
	for i in range(room.doors.size()):
		if room.doors[i] == true:
			count += 1
	var center	
	if count > 2:
		center = _switch.instantiate()
		#Spawn corresponding lever
		var switch_lever : lever = _lever.instantiate() as lever
		inst.add_child(switch_lever)
		#Spawn in diagonal to avoid railse
		switch_lever.position = Vector2(ROOMSIZE.x, -ROOMSIZE.y)/2.0 + Vector2(math.RandomSign(), math.RandomSign()) * lever_distance_to_switch
		
		var spawned_switch : RailSwitch = center as RailSwitch
		switch_lever.on_interacted.connect(spawned_switch._on_switch)
				
	else:
		center = _rail.instantiate()
	inst.add_child(center)
	if _first_rail == null:
		_first_rail = center as Rail
	center.position = Vector2(ROOMSIZE.x, -ROOMSIZE.y)/2.0
	
	if spawn_cart:
		game_manager.Instance.spawn_cart(center.position)
	
	for i in range(0, room.doors.size()):
		
		if(room.doors[i]):
			var dir = possible[i]
			var dest = roomCenter + Vector2(dir) * (ROOMSIZE/2.0)
			var step : int = (roomCenter - dest).length()/ RAILSIZE as int
			var previous_rail : Rail = center
			
			for j in range(1, step+1):
				var pos : Vector2 = Vector2(ROOMSIZE.x, -ROOMSIZE.y)/2.0 + RAILSIZE * j * Vector2(dir)
				var instance = _rail.instantiate()
				inst.add_child(instance)
				instance.position = pos
				var rail : Rail = instance as Rail
				if(previous_rail != null):
					previous_rail.connect_rail(rail)
					
				previous_rail = rail
				
				if j == step:
					room.rails[i] = rail
					
	var possible_dir		
	for k in range(possible.size()):
		possible_dir = possible[k]
		var neighbor_pos :  Vector2 = roomCenter + Vector2(ROOMSIZE.x * possible_dir.x, ROOMSIZE.y * possible_dir.y)
		print(neighbor_pos)
		if rooms.get(neighbor_pos) != null:
			var neighbor : RoomData = rooms[neighbor_pos]
			if(neighbor.rails[_get_opposite_door_index_from_dir(possible_dir)] != null):
				neighbor.rails[_get_opposite_door_index_from_dir(possible_dir)].connect_rail(room.rails[_get_door_index_from_dir(possible_dir)])	
