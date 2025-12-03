class_name Player extends CharacterBody2D

@export var _health : int = 3

@export_category("Movement")
@export var _maxSpeed : float
@export var _maxAccel : float

var _can_move := true

var _input : Vector2 = Vector2(0,0)
var key_count := 0

func _process(_delta: float) -> void:
	get_input()

func _physics_process(delta: float) -> void:
	if (_can_move):
		var targetVelocity = _input * _maxSpeed
		var maxSpeedChange = _maxAccel * delta
		velocity.x = move_toward(velocity.x, targetVelocity.x, maxSpeedChange)
		velocity.y = move_toward(velocity.y, targetVelocity.y, maxSpeedChange)
		move_and_slide()

func get_input() -> void:
	_input = Input.get_vector("Left", "Right", "Up", "Down")
	if(Input.is_action_just_pressed("Interact")):
		_interact()

func _interact() -> void:
	var areas = $InteractionArea.get_overlapping_areas()
	print("interacted")
	for area in areas:
		if (area is Interactable):
			area.interact(self)

func set_can_move(can_move: bool)->void:
	_can_move = can_move

func hit() -> void:
	_health -= 1
	if _health <= 0:
		print("Death")
		_can_move = false
