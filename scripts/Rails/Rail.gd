class_name Rail extends Area2D

@export var dir : Vector2
@export var size := 16.0
@export var is_turning : bool
@export var flip_normal: bool
@export var rail_data: RailData

var connected: Array[Rail]
var is_aligned := false

func get_side_force(other_position: Vector2) -> Vector2:
	var center := position
	var normal := Vector2(-dir.y, dir.x)

	if (is_turning):
		center = position + size/4 * normal if (not flip_normal) else position - size/4 * normal

	var to_other := other_position - center
	return -to_other.dot(normal) * 0.1 *normal

func reverse():
	dir = Vector2(-dir.x, -dir.y)
	if is_turning:
		flip_normal = not flip_normal



func init_rail(next_rail: Rail, previous_rail: Rail) -> void:
	if next_rail != null && previous_rail != null:
		$Sprite2D.region_rect.position = rail_data.get_sprite_coords(self, next_rail, previous_rail)
		connected = [next_rail, previous_rail]
		dir = (next_rail.position - previous_rail.position).normalized()
		flip_normal = dir.x < -rail_data.error # le vecteur normal doit toujours pointer ver l'exterieur du virage
	else:
		print("single connection")
		var connected_rail = next_rail if next_rail != null else previous_rail
		if connected_rail == null : return
		$Sprite2D.region_rect.position = rail_data.get_sprite_coords_single_connection(self, connected_rail)
		connected = [connected_rail]
		dir = connected_rail.position - position
		flip_normal = false
	

func propagate_orientation(constraint: Vector2):
	if dir.dot(constraint) < 0:
		reverse()
	is_aligned = true
	for connected_rail in connected:
		if not connected_rail.is_aligned:
			connected_rail.propagate_orientation(dir)
