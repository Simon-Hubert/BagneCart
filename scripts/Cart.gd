class_name Cart extends CharacterBody2D

var _area : Area2D

@export var _player: Player
@export var _radius: float
var _railDir: Vector2

func _ready():
	_area = $area

func _process(_delta: float) -> void:
	_railDir = Vector2(0,0)
	for area in _area.get_overlapping_areas():
		if(area is Rail):
			_railDir += area.dir
	_railDir = _railDir.normalized()


func _physics_process(delta: float) -> void:
	var toPlayer := _player.position - position
	print((_player.position - position).length())
	var p := inverse_lerp(_radius, 0, (toPlayer).length()) # la puissance normalisée de l'impac
	p = clamp(p, 0, 1)
	var speed := (-toPlayer).normalized().dot(_railDir) * p * 100 * _railDir
	position += speed*delta

	


	
