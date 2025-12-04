class_name Player extends CharacterBody2D

@onready var knockback_timer = $KnockbackTimer
@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer

@export_category("Health")
@export var _health : int = 3
@export var _max_health : int = 5

@export_category("Movement")
@export var _maxSpeed : float
@export var _maxAccel : float
@export var _knockback_intensity : float

var _can_move := true
var _is_knockbacked := false
var _input : Vector2 = Vector2(0,0)

var key_count := 0
var is_dead := false

signal on_player_setup_health(defaultHealth : int)
signal on_player_update_health(newHealth : int)

func _ready() -> void:
	on_player_setup_health.emit(_health)

func _process(_delta: float) -> void:
	get_input()

func _physics_process(delta: float) -> void:
	if (_can_move):
		if !_is_knockbacked:
			var targetVelocity = _input * _maxSpeed
			var maxSpeedChange = _maxAccel * delta
			velocity.x = move_toward(velocity.x, targetVelocity.x, maxSpeedChange)
			velocity.y = move_toward(velocity.y, targetVelocity.y, maxSpeedChange)
		move_and_slide()

func get_input() -> void:
	_input = Input.get_vector("Left", "Right", "Up", "Down")
	#flip the sprite relative to the direction
	if _input.x != 0 && _can_move:
		sprite.flip_h = _input.x < 0
	#interact key
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

##Restore one health point
func restore_health():
	_health = mini(_health + 1, _max_health)
	on_player_update_health.emit(_health)

##Remove one health point
##dir = hit direction
func hit(dir : Vector2) -> void:
	_health -= 1
	on_player_update_health.emit(_health)
	#Knockback the player
	_is_knockbacked = true
	velocity = dir * _knockback_intensity
	knockback_timer.start()	
	#Check player death
	if _health <= 0:
		animation_player.play("Death")
		_can_move = false
		is_dead = true
	else:
		animation_player.play("Hit")

##Event when timer ended
func _on_knockback_ended() -> void:
	_is_knockbacked = false
