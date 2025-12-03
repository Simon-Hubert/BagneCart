class_name enemy extends CharacterBody2D

const TILE_SIZE : int = 16

@onready var sprite = $Sprite2D
@onready var attack_shape = $AttackArea/CollisionShape2D
@onready var attack_timer = $AttackTimer

@export_category("References")
@export var player_ref : Player
@export var cart_ref : Cart

@export_category("Enemies types")
@export var enemies_type : Array[enemy_data]

var speed : float = 500
var max_accel : float = 750
var is_shooting : bool = false
var direction : Vector2 = Vector2(0,0)
var can_attack : bool = true

var is_player_in_range : bool = false
var is_cart_in_range : bool = false
#Ennemis qui lance des projectiles


func _ready():
	#Choose random enemy
	var rng = RandomNumberGenerator.new()
	_setup(enemies_type[rng.randi() % enemies_type.size()])

func _setup(data : enemy_data):
	sprite.region_rect = Rect2(data.tilemap_offset.x, data.tilemap_offset.y, TILE_SIZE, TILE_SIZE)
	speed = data.speed
	max_accel = data.max_accel
	is_shooting = data.is_shooting
	attack_shape.shape.radius = data.attack_ange
	attack_timer.wait_time = data.attack_cooldown_timer

func _process(_delta: float) -> void:
	#Check which is closer
	var distance_to_player : float = player_ref.position.distance_to(position)
	var distance_to_cart : float = cart_ref.position.distance_to(position)
	if distance_to_player < distance_to_cart :
		#move to player
		direction = (player_ref.position - position).normalized()
	else :
		direction = (cart_ref.position - position).normalized()
		pass

	#Check if can hit, and to who
	if can_attack:
		if is_player_in_range:
			var dir_to_player = (player_ref.position - position).normalized()
			player_ref.hit(dir_to_player)
			attack_timer.start()
			can_attack = false
		elif is_cart_in_range:
			push_warning("Demander a simon comment mather")
			attack_timer.start()
			can_attack = false
			
func _physics_process(delta: float) -> void:
	var targetVelocity = direction * speed
	var maxSpeedChange = max_accel * delta
	velocity.x = move_toward(velocity.x, targetVelocity.x, maxSpeedChange)
	velocity.y = move_toward(velocity.y, targetVelocity.y, maxSpeedChange)
	move_and_slide()

func _on_attack_area_body_entered(body: Node2D) -> void:
	match body.name:
		"Player":
			is_player_in_range = true
		"Cart":
			is_cart_in_range = true

func _on_attack_area_body_exited(body: Node2D) -> void:
	match body.name:
		"Player":
			is_player_in_range = false
		"Cart":
			is_cart_in_range = false

func _reset_attack() -> void:
	can_attack = true
