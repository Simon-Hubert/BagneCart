class_name Cart extends Node2D

var _area : Area2D

@export var _player: Player
@export var _radius: float
@export var _max_accel: float
@export var _friction: float
var _lin_speed: float

func _ready():
	_area = $area


func _physics_process(delta: float) -> void:
	var rail_dir : Vector2
	var centered : Vector2
	var space_state = get_world_2d().direct_space_state
	var point := PhysicsPointQueryParameters2D.new()
	point.collide_with_areas = true
	point.position = position
	point.exclude = [$area]
	var result = space_state.intersect_point(point)

	for collider in result:
		if(collider.collider is Rail):
			rail_dir = collider.collider.dir
			centered = collider.collider.get_side_force(position)/2
			break
	
	var toPlayer := _player.position - position
	var p := inverse_lerp(_radius, 0, (toPlayer).length()) # la puissance normalisée de l'impac
	p = clamp(p, 0, 1)
	print(p)

	_lin_speed += p * (-toPlayer).normalized().dot(rail_dir) *_max_accel*delta
	_lin_speed -= (_friction*_lin_speed)*delta
	var speed :=  _lin_speed  * rail_dir #
	position += speed*delta
	position += centered

	

	


	
