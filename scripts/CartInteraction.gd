class_name CartInteraction extends Interactable

var player_in := false

signal player_hopped_in()
signal player_hopped_out()

func interact(player: Player):
	if(player_in):
		player_in = false
		player.reparent(get_tree().root)
		player.set_can_move(true)
		player_hopped_out.emit()
	else:
		player_in = true
		player.reparent(self)
		player.position = Vector2(0,0)
		player.set_can_move(false)
		player_hopped_in.emit()
	
