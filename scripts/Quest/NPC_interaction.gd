class_name NPC_interaction extends Interactable

signal player_interact()

func interact(_player: Player):
	player_interact.emit()
