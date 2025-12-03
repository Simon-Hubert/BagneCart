class_name Cart extends Node2D

var _area : Area2D

@export var _player: Player
@export var _radius: float
@export var _max_accel: float
@export var _friction: float
var _lin_speed: float
var _no_friction := false
var _rail_dir : Vector2

func _ready():
	_area = $area
	$CartInteraction.player_hopped_in.connect(_on_player_hopped_in)
	$CartInteraction.player_hopped_out.connect(_on_player_hopped_out)


func _physics_process(delta: float) -> void:
	var centered : Vector2
	var space_state = get_world_2d().direct_space_state
	var point := PhysicsPointQueryParameters2D.new()
	point.collide_with_areas = true
	point.position = position
	point.exclude = [$area]
	var result = space_state.intersect_point(point)

	for collider in result:
		if(collider.collider is Rail):
			_rail_dir = collider.collider.dir
			centered = collider.collider.get_side_force(position)/2
			break
	
	var toPlayer := _player.position - position
	var p := inverse_lerp(_radius, 0, (toPlayer).length()) # la puissance normalisée de l'impac
	p = clamp(p, 0, 1)

	if(not _no_friction):
		_lin_speed += p * (-toPlayer).normalized().dot(_rail_dir) * _max_accel * delta
		_lin_speed -= (_friction*_lin_speed)*delta
	
	var speed :=  _lin_speed  * _rail_dir #
	position += speed*delta
	position += centered

func _on_player_hopped_in() -> void:
	_no_friction = true

func _on_player_hopped_out() -> void:
	_no_friction = false

## To push the cart with a force
##
## @experimental not tested
func push(force: Vector2) -> void:
	_lin_speed += (force).normalized().dot(_rail_dir)