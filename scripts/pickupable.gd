class_name Pickupable extends Interactable

signal on_picked_up()

var is_picked_up := false

func interact(player: Player):
	if is_picked_up:
		return
	player.pick_item(self)
	is_picked_up = true	
	on_picked_up.emit()
	
