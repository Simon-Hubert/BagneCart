class_name Player extends CharacterBody2D

@export var _maxSpeed : float
@export var _maxAccel : float

var _input : Vector2 = Vector2(0,0)
var key_count := 0

func _process(_delta: float) -> void:
	get_input()

func _physics_process(delta: float) -> void:
	var targetVelocity = _input * _maxSpeed
	var maxSpeedChange = _maxAccel * delta
	velocity.x = move_toward(velocity.x, targetVelocity.x, maxSpeedChange)
	velocity.y = move_toward(velocity.y, targetVelocity.y, maxSpeedChange)
	move_and_slide()

func get_input() -> void:
	_input = Input.get_vector("Left", "Right", "Up", "Down")
	print(_input)

