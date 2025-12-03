class_name NPC_interaction extends Interactable

signal player_interact()

func interact(player: Player):
	player_interact.emit()
