extends CanvasLayer

@export var heart_scene : PackedScene
@export var life_container : BoxContainer #= $"LifeContainer"

var previous_life : int

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
