class_name enemy_data extends Resource

@export var sprite_texture : Texture2D
@export var speed : float = 10.0
@export var max_accel : float = 20.0
@export var is_shooting : bool = true
@export var attack_close_range : float = 14.0 #For hand-to-hand range
@export var attack_far_range : float = 100 #For projectile range
@export var attack_cooldown_timer : float = 1.0
