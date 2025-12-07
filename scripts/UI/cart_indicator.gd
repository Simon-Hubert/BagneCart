class_name cart_indicator extends Control

@onready var arrow : TextureRect = $Arrow
@onready var cart_icon : TextureRect = $Arrow/CartIcon

@export_category("References")
@export var camera : Camera2D
@export var player : Player
@export var cart : Cart

func _ready() -> void:
	#hide arrow by default
	arrow.visible = false
	
	 #connect to cart signals
	if !cart :
		push_error("Cart reference isn't set")
		return
	cart.on_enter_screen.connect(_hide_icon)
	cart.on_exit_screen.connect(_show_icon)

func _process(_delta: float) -> void:
	#Check if arrow is shown
	if !arrow.visible:
		return
		
	#Update rotation
	var diff : Vector2 = cart.position - player.position
	var angle : float = rad_to_deg(atan2(diff.y, diff.x))
	arrow.rotation = diff.angle() + 90
	
	#Set clamped position
	var cart_screen_pos: Vector2 = ((cart.global_position - camera.global_position).normalized() * get_viewport_rect().size) + (get_viewport_rect().size / 2)
	const margin : Vector2 = Vector2(30.0, 30.0)
	const end_margin : Vector2 = Vector2(100.0, 100.0)
	arrow.position = cart_screen_pos.clamp( margin, get_viewport_rect().size - end_margin - arrow.texture.get_size())
	
	#Set global cart icon rotation
	cart_icon.rotation = -arrow.rotation
	
func _show_icon():
	arrow.visible = true
	
func _hide_icon():
	arrow.visible = false
