class_name enemy extends CharacterBody2D

const TILE_SIZE : int = 16
const CART_AREA_NAME = "CartInteraction"

const PROJECTILE_SCENE_PATH : String = "res://scenes/enemy_projectile.tscn" 
const PROJECTILE_SCENE : PackedScene = preload(PROJECTILE_SCENE_PATH)

@onready var sprite = $Sprite2D
@onready var attack_shape = $AttackArea/CollisionShape2D
@onready var range_attack_shape = $RangeAttackArea/CollisionShape2D
@onready var attack_timer = $AttackTimer

@export_category("References")
@export var player_ref : Player
@export var cart_ref : Cart

@export_category("Enemies types")
@export var enemies_type : Array[enemy_data]

@export_category("Parameter")
@export var enemy_cart_push : float = 100

var speed : float = 500
var max_accel : float = 750
var is_shooting : bool = false
var direction : Vector2 = Vector2(0,0)
var can_attack : bool = true

var is_player_in_range : bool = false
var is_cart_in_range : bool = false

func _ready():
	#Choose random enemy
	var rng = RandomNumberGenerator.new()
	_setup(enemies_type[rng.randi() % enemies_type.size()])

func _setup(data : enemy_data):
	sprite.region_rect = Rect2(data.tilemap_offset.x, data.tilemap_offset.y, TILE_SIZE, TILE_SIZE)
	speed = data.speed
	max_accel = data.max_accel
	is_shooting = data.is_shooting
	attack_shape.shape.radius = data.attack_close_range
	range_attack_shape.shape.radius = data.attack_far_range
	attack_timer.wait_time = data.attack_cooldown_timer

func _process(_delta: float) -> void:
	#Check which is closer
	var distance_to_player : float = player_ref.global_position.distance_to(global_position)
	var distance_to_cart : float = cart_ref.global_position.distance_to(global_position)
	
	#move to closest
	var dir_to_player : Vector2 = (player_ref.global_position - global_position).normalized()
	var dir_to_cart: Vector2 = (cart_ref.global_position - global_position).normalized()
	direction = dir_to_player if distance_to_player < distance_to_cart else dir_to_cart

	if can_attack:
		if is_cart_in_range:
			cart_ref.push(dir_to_cart, enemy_cart_push)
			attack_timer.start()
			can_attack = false
			return
		
		if is_player_in_range:
			if is_shooting:
				#range attack (spawn new projectile)
				var newProjectile := PROJECTILE_SCENE.instantiate() as ennemy_projectile
				get_tree().current_scene.add_child(newProjectile)
				newProjectile.position = global_position
				newProjectile.set_velocity(dir_to_player)
				attack_timer.start()
				can_attack = false
				return
				
			#close attack
			player_ref.hit(dir_to_player)
			attack_timer.start()
			can_attack = false
		
			
func _physics_process(delta: float) -> void:
	var targetVelocity = direction * speed
	var maxSpeedChange = max_accel * delta
	velocity.x = move_toward(velocity.x, targetVelocity.x, maxSpeedChange)
	velocity.y = move_toward(velocity.y, targetVelocity.y, maxSpeedChange)
	move_and_slide()

#Reset attack when timer ends
func _reset_attack() -> void:
	can_attack = true
	
##Check if player is in range for close attack
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body is Player && !is_shooting:
		is_player_in_range = true
##Check if player is NOT in range for close attack
func _on_attack_area_body_exited(body: Node2D) -> void:
	if body is Player && !is_shooting:
		is_player_in_range = false

##Check if cart is in range to be pushed
func _on_attack_area_area_entered(area: Area2D) -> void:
	if area.name == CART_AREA_NAME:
		is_cart_in_range = true
##Check if cart is NOT in range to be pushed
func _on_attack_area_area_exited(area: Area2D) -> void:
	if area.name == CART_AREA_NAME:
		is_cart_in_range = false

##Check if player is in range for range attack
func _on_range_attack_area_body_entered(body: Node2D) -> void:
	if body is Player && is_shooting:
		is_player_in_range = true
##Check if player is NOT in range for range attack
func _on_range_attack_area_body_exited(body: Node2D) -> void:
	if body is Player && is_shooting:
		is_player_in_range = false
