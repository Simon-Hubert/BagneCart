class_name enemy extends CharacterBody2D

const TILE_SIZE : int = 16
const CART_AREA_NAME = "CartInteraction"

const PROJECTILE_SCENE_PATH : String = "res://scenes/Enemy/enemy_projectile.tscn" 
const PROJECTILE_SCENE : PackedScene = preload(PROJECTILE_SCENE_PATH)

static var _health_drop_proba_modifier : float = 0

@onready var sprite = $Sprite2D
@onready var attack_shape = $AttackArea/CollisionShape2D
@onready var range_attack_shape = $RangeAttackArea/CollisionShape2D
@onready var attack_timer = $AttackTimer
@onready var cart_cooldown_timer : Timer = $CartCooldownTimer
@onready var animation_player = $AnimationPlayer
@onready var self_collision : CollisionShape2D = $CollisionShape2D

@export_category("Health")
@export var _health : int = 3
var is_dead := false

@export_category("References")
@export var player_ref : Player
@export var cart_ref : Cart

@export_category("Enemies types")
@export var enemies_type : Array[enemy_data]

@export_category("Parameter")
@export var _enemy_cart_push : float = 100
@export_range(0,1) var _health_potion_drop_rate : float = 0.25
@export var _health_drop_proba_modifier_factor : float = 5

var speed : float = 500
var max_accel : float = 750
var is_shooting : bool = false
var direction : Vector2 = Vector2(0,0)
var can_attack : bool = true
var can_focus_cart : bool = true
var is_player_in_range : bool = false
var is_cart_in_range : bool = false
var is_active : bool = true

func _ready():
	#Choose random enemy
	var rng = RandomNumberGenerator.new()
	_setup(enemies_type[rng.randi() % enemies_type.size()])
	
##Setup enemy data from an enemy_data resource
func _setup(data : enemy_data):
	sprite.texture = data.sprite_texture
	speed = data.speed
	max_accel = data.max_accel
	is_shooting = data.is_shooting
	attack_shape.shape.radius = data.attack_close_range
	range_attack_shape.shape.radius = data.attack_far_range
	attack_timer.wait_time = data.attack_cooldown_timer

func _process(_delta: float) -> void:
	#Check references (and if player didn't died) and if is active
	if !player_ref || !cart_ref || !is_active:
		return
	if player_ref.is_dead:
		return
	if is_dead:
		return
	animation_player.play("Move")
	
	#Check which is closer
	var distance_to_player : float = player_ref.global_position.distance_to(global_position)
	var distance_to_cart : float = cart_ref.global_position.distance_to(global_position)
	
	#move to closest
	var dir_to_player : Vector2 = (player_ref.global_position - global_position).normalized()
	var dir_to_cart: Vector2 = (cart_ref.global_position - global_position).normalized()
	direction = dir_to_player if distance_to_player < distance_to_cart || !can_focus_cart else dir_to_cart

	if can_attack:
		if is_cart_in_range && can_focus_cart:
			cart_ref.push(dir_to_cart, _enemy_cart_push)
			cart_cooldown_timer.start()
			attack_timer.start()
			can_focus_cart = false
			can_attack = false
			return
		
		if is_player_in_range:
			animation_player.play("Attack")
			attack_timer.start()
			can_attack = false
			if is_shooting:
				#range attack (spawn new projectile)
				var newProjectile := PROJECTILE_SCENE.instantiate() as ennemy_projectile
				get_tree().current_scene.add_child(newProjectile)
				newProjectile.position = global_position
				newProjectile.set_velocity(dir_to_player)
				return
				
			#close attack
			player_ref.hit(dir_to_player)
		
			
func _physics_process(delta: float) -> void:
	#Check references
	if !player_ref || !cart_ref || !is_active:
		return
	if player_ref.is_dead:
		return
	if is_dead:
		return
			
	#Move towards target
	var targetVelocity = direction * speed
	var maxSpeedChange = max_accel * delta
	velocity.x = move_toward(velocity.x, targetVelocity.x, maxSpeedChange)
	velocity.y = move_toward(velocity.y, targetVelocity.y, maxSpeedChange)
	move_and_slide()

##dir for knockback
func hit(_dir : Vector2) -> void:
	_health -= 1
	#Check death
	if _health <= 0:
		animation_player.play("Death")
		is_dead = true
		call_deferred("disable_collision")
		#Drop a potion
		if quest_manager.Instance.rng.randf() <= _health_potion_drop_rate + _health_drop_proba_modifier:
			game_manager.Instance.spawn_health_potion(global_position)
			_health_drop_proba_modifier -= _health_drop_proba_modifier_factor
		else:
			_health_drop_proba_modifier += _health_drop_proba_modifier_factor
	else:
		animation_player.play("Hit")

##Disable the enemy collision
func disable_collision() -> void:
	self_collision.disabled = true

##Reset attack when timer ends
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
		
##Reset focus on cart
func _on_cart_cooldown_timer_timeout() -> void:
	can_focus_cart = true

##Activate the enemy if is in the room
func _activate_enemy() -> void:
	is_active = true

##Activate the enemy if not in the room anymore
func _deactivate_enemy() -> void:
	is_active = false
