class_name camera_zelda_style extends Camera2D

@export_category("Reference")
@export var player_ref : Player

@export_category("Limit")
@export var screen_limit : Vector2 = Vector2(150,90)
@export var camera_offset : Vector2 = Vector2(300,180)
@export var _decay : float
@export var _distance_threshold : float

var _target_camera_position : Vector2
var _is_cam_moving : bool = false

func _ready() -> void:
	player_ref.on_player_exited_screen.connect(_follow_player)
	_target_camera_position = global_position
	
##Follow player to next room if changed
func _process(delta: float) -> void:
	if !_is_cam_moving:
		return
	#Move camera until reach target
	global_position = math.exponential_decay(position, _target_camera_position, _decay, delta)
	if global_position.distance_to(_target_camera_position) <= _distance_threshold:
		_is_cam_moving = false
	
##Find player and follow it (like in the popular dungeon sequence of the ledgend of Zelda)
func _follow_player() -> void:
	var player_screen_position = to_local(player_ref.global_position)
	if player_screen_position.y <= -screen_limit.y:
		set_camera_movement(Vector2(0,-1))
	elif player_screen_position.y >= screen_limit.y:
		set_camera_movement(Vector2(0,1))
	elif player_screen_position.x >= screen_limit.x :
		set_camera_movement(Vector2(1,0))
	elif player_screen_position.x <= -screen_limit.x :
		set_camera_movement(Vector2(-1,0))
	
##To respect DRY (Don't Repeat Yourself), set camera movement parameters here
func set_camera_movement(dir : Vector2):
	_is_cam_moving = true
	_target_camera_position = global_position + camera_offset * dir
