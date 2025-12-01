class_name Rail extends Area2D

@export var _up : bool
@export var _down : bool
@export var _left : bool
@export var _right : bool

var dir : Vector2

## [b]Protected[/b]: Sets the rail direction assuming positive travel is upwards.[br]
## 
## the [code]x[/code] component reflects if there is vertical movement or not (0 or -1).[br]
## The [code]y[/code] component is the horizontal movement (-1, 0 or 1).
func _setDir() -> void:
	if (_up && _down):
		dir = Vector2(0,-1)
		return

	if (_left && _right):
		dir = Vector2(1,0)
		return

	var h = (_right as int)-(_left as int)
	var v = -1
	if (_up):
		h = -h
	dir = Vector2(h,v)

func _ready():
	_setDir()