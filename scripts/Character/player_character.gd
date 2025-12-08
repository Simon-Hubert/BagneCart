class_name Player extends CharacterBody2D

@onready var knockback_timer = $KnockbackTimer
@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer

@export_category("Health")
@export var _default_health : int = 3
@export var _max_health : int = 5

@export_category("Movement")
@export var _maxSpeed : float
@export var _maxAccel : float
@export var _knockback_intensity : float


@export_category("Attack")
@export var _attack_cooldown : float
@export var _attack_offset : float
var _can_attack := true

const ATTACK_SCENE_PATH : String = "res://scenes/player_attack.tscn" 
const ATTACK_SCENE : PackedScene = preload(ATTACK_SCENE_PATH)

var _can_move := true
var _is_knockbacked := false
var _input : Vector2 = Vector2(0,0)
var _health : int

var key_count := 0
var is_dead := false

var _default_position : Vector2

signal on_player_setup_health(defaultHealth : int)
signal on_player_update_health(newHealth : int)
signal on_player_exited_screen

func _ready() -> void:
	_health = _default_health
	on_player_setup_health.emit(_health)
	_default_position = global_position
	game_manager.Instance.on_respawn.connect(_respawn_player)
	game_manager.Instance.on_game_over.connect(_on_game_over)
	
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
	#attack key
	if(Input.is_action_just_pressed("Attack")):
		_attack()

func _interact() -> void:
	var areas = $InteractionArea.get_overlapping_areas()
	areas = areas.filter(func(ar):return (ar is Interactable))
	areas.sort_custom(func(a,b): return (a.interaction_priority > b.interaction_priority))
	for area in areas:
		if area.can_fail :
			if area.try_interact(self):
				break
		else:
			area.interact(self)
			break

	if not $PickedItem.empty:
		$PickedItem.drop_item()

func _attack() -> void :
	if not _can_attack:
		return
	_start_attack_cooldown()
	var new_attack = ATTACK_SCENE.instantiate() as PlayerAttack
	add_child(new_attack)
	var dir = _input if _input != Vector2(0,0) else Vector2.RIGHT
	new_attack.position = _attack_offset * dir
	new_attack.direction = dir
	dir = Vector2(-dir.y, dir.x)
	new_attack.rotation = atan2(dir.y, dir.x)


func _start_attack_cooldown() -> void :
	_can_attack = false
	await get_tree().create_timer(_attack_cooldown).timeout
	_can_attack = true
	
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
		game_manager.Instance.respawn_player()
	else:
		animation_player.play("Hit")

##Event when timer ended
func _on_knockback_ended() -> void:
	_is_knockbacked = false

##Pick an item
func pick_item(item: Pickupable) -> void:
	$PickedItem.pick_item(item)

##Signal when the player exited the screen
func _on_screen_exited() -> void:
	on_player_exited_screen.emit()

##Respawn player to the default (spawning) position
func _respawn_player() -> void:
	global_position = _default_position
	is_dead = false
	_can_move = true
	_health = _default_health
	on_player_setup_health.emit(_health)
	animation_player.play("RESET")

##Stop the player when the player fails
func _on_game_over() -> void:
	_can_move = false
