class_name RailData extends Resource

enum RailShape{
	TOP_BOTTOM,
	TOP_LEFT,
	TOP_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_RIGHT,
	LEFT_RIGHT
}   

static var error : float = 0.01

@export var shape_to_sprite_coord : Dictionary[RailShape, Vector2]

func get_sprite_coords(owner: Rail, c0: Rail, c1: Rail) -> Vector2:
	return shape_to_sprite_coord[c_to_shape(owner, c0, c1)]

static func c_to_shape(owner: Rail, c0: Rail, c1: Rail) -> RailShape:
	var a = (c0.global_position - owner.global_position).normalized()
	var b = (c1.global_position - owner.global_position).normalized()

	if a.dot(Vector2.UP) > error :
		if b.dot(Vector2.LEFT) > error:
			return RailShape.TOP_LEFT
		if b.dot(Vector2.RIGHT) > error:
			return RailShape.TOP_RIGHT
		if b.dot(Vector2.DOWN) > error:
			return RailShape.TOP_BOTTOM
	if a.dot(Vector2.DOWN) > error:
		if b.dot(Vector2.LEFT) > error:
			return RailShape.BOTTOM_LEFT
		if b.dot(Vector2.RIGHT) > error:
			return RailShape.BOTTOM_RIGHT
	
	if b.dot(Vector2.UP) > error :
		if a.dot(Vector2.LEFT) > error:
			return RailShape.TOP_LEFT
		if a.dot(Vector2.RIGHT) > error:
			return RailShape.TOP_RIGHT
		if a.dot(Vector2.DOWN) > error:
			return RailShape.TOP_BOTTOM
	if b.dot(Vector2.DOWN) > error:
		if a.dot(Vector2.LEFT) > error:
			return RailShape.BOTTOM_LEFT
		if a.dot(Vector2.RIGHT) > error:
			return RailShape.BOTTOM_RIGHT
	
	return RailShape.LEFT_RIGHT

func get_sprite_coords_single_connection(owner: Rail, c0: Rail) -> Vector2:
	#TODO implement
	return Vector2(0,0)
	
