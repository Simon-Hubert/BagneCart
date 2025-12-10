class_name Rail extends Area2D

@export var dir : Vector2
@export var size := 16.0
@export var is_turning : bool
@export var flip_normal: bool
@export var rail_data: RailData

var connected: Array[Rail] = [null, null]
var is_aligned := false
var is_end_of_line := false

func get_side_force(other_position: Vector2) -> Vector2:
	var center := global_position
	var normal := Vector2(-dir.y, dir.x)
	if (is_turning):
		center = global_position - size/4 * normal if (not flip_normal) else global_position + size/4 * normal
	var to_other := other_position - center

	return -to_other.dot(normal) * 0.1 * normal

func reverse():
	dir = Vector2(-dir.x, -dir.y)
	if is_turning:
		flip_normal = not flip_normal

func connect_rail(to_connect :Rail) :
	if connected.find(to_connect) != -1 : return
	connected.append(to_connect)
	to_connect.connect_rail(self)
	is_end_of_line = (connected[-1] != null) || (connected[-2] != null)
	init_rail(connected[-2], connected[-1])

func disconnect_rail(to_disconnect: Rail) -> void:
	var index = connected.find(to_disconnect)
	if index != -1 :
		connected.remove_at(index)
		to_disconnect.disconnect_rail(self)
		is_end_of_line = (connected[-1] != null) || (connected[-2] != null)
		init_rail(connected[-2], connected[-1])

func init_rail(next_rail: Rail, previous_rail: Rail) -> void:
	if next_rail != null && previous_rail != null:
		$Sprite2D.region_rect.position = rail_data.get_sprite_coords(self, next_rail, previous_rail)
		dir = (next_rail.global_position - previous_rail.global_position).normalized()
		flip_normal = dir.x < -rail_data.error # le vecteur normal doit toujours pointer ver l'exterieur du virage
		is_turning = abs((position - next_rail.position).dot(position - previous_rail.position)) < rail_data.error
		is_end_of_line = false 
	else:
		var connected_rail = next_rail if next_rail != null else previous_rail
		if connected_rail == null : return
		$Sprite2D.region_rect.position = rail_data.get_sprite_coords_single_connection(self, connected_rail)
		dir = connected_rail.global_position - global_position
		flip_normal = false
		is_end_of_line = true
	
func propagate_orientation(constraint: Vector2):
	if dir.dot(constraint) < 0:
		if not is_end_of_line:
			reverse()
	is_aligned = true
	for connected_rail in connected:
		if connected_rail == null : continue
		if not connected_rail.is_aligned:
			connected_rail.propagate_orientation(dir)
	
