class_name quest_indicator extends Control

@onready var arrow : TextureRect = $Arrow
@onready var quest_icon : TextureRect = $Arrow/CartIcon

@export_category("References")
@export var camera : Camera2D
@export var player : Player

@export_category("Param")
@export var minimum_distance : float = 10

func _ready() -> void:
	game_manager.Instance.on_setup_UI.connect(setup_UI)

func setup_UI() -> void:
	#hide arrow by default
	arrow.visible = false
	
	#Setup references
	camera = game_manager.Instance.camera_ref
	player = game_manager.Instance.player_ref
	quest_manager.Instance.on_quest_recieved.connect(_setup_indicator)

##Set up the icon once a quest is accpeted
func _setup_indicator():
	quest_icon.texture = quest_manager.Instance.get_current_quest_item_sprite()

func _process(_delta: float) -> void:
	#Check if arrow is shown (or if is missing a reference)
	arrow.visible = quest_manager.Instance.has_quest
	if !arrow.visible || ! player || !camera:
		return
		
	var item_distance : float
	var item_position : Vector2 
	
	var cloest_item_position : quest_manager.closest_quest_item_data = quest_manager.Instance.get_closest_quest_item(player.global_position)
	item_distance = cloest_item_position.distance
	item_position = cloest_item_position.position
	
	#Check if not too close
	if minimum_distance >= item_distance:
		arrow.visible = false
		return
	
	#Update rotation
	var diff : Vector2 = item_position - player.global_position
	arrow.rotation_degrees = rad_to_deg(diff.angle()) + 90
	
	#Set clamped position
	var quest_screen_pos: Vector2 = (diff.normalized() * get_viewport_rect().size) + (get_viewport_rect().size / 2)
	const margin : Vector2 = Vector2(30.0, 30.0)
	const end_margin : Vector2 = Vector2(100.0, 100.0)
	arrow.position = quest_screen_pos.clamp( margin, get_viewport_rect().size - end_margin - arrow.texture.get_size())
	
	#Set global quest icon rotation
	quest_icon.rotation = -arrow.rotation
	
func _show_icon():
	arrow.visible = true
	
func _hide_icon():
	arrow.visible = false
