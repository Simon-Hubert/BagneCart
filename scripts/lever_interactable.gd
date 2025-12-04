class_name lever_interaction extends Interactable

signal player_interact()

func interact(_player: Player):
	player_interact.emit()
