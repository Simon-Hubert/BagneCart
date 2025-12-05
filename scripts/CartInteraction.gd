class_name CartInteraction extends Interactable

var player_in := false
var item_in := false
var cooldown := 0.5
var can_work := true
var item : Pickupable

signal player_hopped_in()
signal player_hopped_out()

func _ready():
	can_fail = true #c'est degeu a cause du language

func try_interact(player: Player) -> bool:
	if not can_work:
		return false

	if try_put_item(player):
		start_cooldown()
		return true

	if not item_in :
		put_player(player)
		start_cooldown()
		return true
	return false

	
func try_put_item(player) -> bool:
	if player.get_node("PickedItem").empty:
		return false
	item = player.get_node("PickedItem").transfer_item()
	if item == null:
		return true
	item_in = true
	item.reparent(self)
	item.position = Vector2(0,0)
	item.on_picked_up.connect(_on_item_picked_up)
	item.is_in_cart = true
	return true
		

func put_player(player: Player):
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

func _on_item_picked_up() -> void:
	item.on_picked_up.disconnect(_on_item_picked_up)
	start_cooldown()
	item_in = false
	item.is_in_cart = false

func start_cooldown():
	can_work = false
	await get_tree().create_timer(cooldown).timeout
	can_work = true

