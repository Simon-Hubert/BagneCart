extends CanvasLayer

@export var life_container : BoxContainer #= $"LifeContainer"
@export var quest_failed_container : BoxContainer
@export var heart_scene : PackedScene
@export var cross_scene : PackedScene

var previous_life : int

func _ready() -> void:
	game_manager.Instance.on_quest_failed.connect(_add_cross)
	game_manager.Instance.on_setup_UI.connect(setup_UI)
	
func setup_UI() -> void:
	game_manager.Instance.player_ref.on_player_setup_health.connect(_on_setup_lives)
	game_manager.Instance.player_ref.on_player_update_health.connect(_on_life_changed)
	game_manager.Instance.player_ref.on_player_setup_health.emit(game_manager.Instance.player_ref._health)
	
##Setup a number of lives by default
func _on_setup_lives(number_lives : int) -> void:
	previous_life = number_lives
	for heart in previous_life:
		_add_heart()
	
##Add / remove a life based on new health
func _on_life_changed(new_life : int) -> void:
	if new_life < previous_life:
		_remove_heart()
	elif new_life > previous_life:
		_add_heart()
	previous_life = new_life
	
##Add a heart to the UI
func _add_heart() -> void:
	var heart = heart_scene.instantiate()
	life_container.add_child(heart)

##Remove a heart to the UI
func _remove_heart() -> void:
	if life_container.get_child_count() == 0:
		return

	var heart =	life_container.get_child(0)
	life_container.remove_child(heart)

##Add  quest failed to the UI
func _add_cross() -> void:
	var new_cross = cross_scene.instantiate()
	quest_failed_container.add_child(new_cross)
