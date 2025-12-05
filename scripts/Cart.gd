class_name Cart extends Node2D

const _tile_set_horizontal_offset : float = 96.0 
const _tile_set_vertical_offset : float = 112.0 
const _tile_set_diagonal_offset : float = 128.0 

@onready var _cart_interaction = $CartInteraction
@onready var _sprite : Sprite2D = $Sprite2D
@onready var _animation_player : AnimationPlayer = $AnimationPlayer

@export var _player: Player
@export var _radius: float
@export var _max_accel: float
@export var _friction: float

var _lin_speed: float
var _no_friction := false
var _rail_dir : Vector2

func _ready():
	_cart_interaction.player_hopped_in.connect(_on_player_hopped_in)
	_cart_interaction.player_hopped_out.connect(_on_player_hopped_out)

func _process(_delta: float) -> void:
	#Change tile set in function of rail direction
	if _rail_dir.y != 0:
		set_tile_set_X_offset(_tile_set_vertical_offset)
		if _rail_dir.x != 0:
			set_tile_set_X_offset(_tile_set_diagonal_offset)
			_sprite.flip_h = (_rail_dir.x > 0) != (_rail_dir.y > 0)
	elif _rail_dir.x != 0:
		set_tile_set_X_offset(_tile_set_horizontal_offset)
		
func _physics_process(delta: float) -> void:
	var centered : Vector2
	var space_state = get_world_2d().direct_space_state
	var point := PhysicsPointQueryParameters2D.new()
	point.collide_with_areas = true
	point.position = position
	point.exclude = [$CartInteraction]
	var result = space_state.intersect_point(point)

	for collider in result:
		if(collider.collider is Rail):
			_rail_dir = collider.collider.dir.normalized()
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
func push(force: Vector2, strengh : float) -> void:
	_lin_speed += (force).normalized().dot(_rail_dir) * strengh
	_animation_player.play("Push")

##Set the X value in the region rect
func set_tile_set_X_offset(x_offset : float) -> void:
	_sprite.region_rect = Rect2(x_offset, 64,16,16)
