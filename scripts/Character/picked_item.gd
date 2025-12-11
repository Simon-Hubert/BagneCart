class_name PickedItem extends Node2D

var empty := true
var _current_item : Pickupable
var can_put_down := false
var is_timer_running := false
var put_down_cooldown := 0.5

signal on_item_picked(Pickupable)
signal on_item_dropped

func get_item() -> Pickupable:
	return _current_item

func pick_item(item: Pickupable) -> void:
	if not empty :
		return
	else:
		item.reparent(self)
		item.position = Vector2(0,0)
		_current_item = item
		on_item_picked.emit(item)
		empty = false
		can_put_down = false
		if not is_timer_running:
			is_timer_running = true
			await get_tree().create_timer(put_down_cooldown).timeout
			can_put_down = true
			is_timer_running = false
		

func drop_item() -> void:
	if empty || not can_put_down:
		return
	_current_item.reparent(get_tree().root)
	_current_item.global_position = get_parent().global_position
	_current_item.is_picked_up = false
	_current_item = null
	on_item_dropped.emit()
	empty = true

func transfer_item() -> Pickupable:
	if empty || not can_put_down:
		return null
	var to_return := _current_item
	_current_item.reparent(get_tree().root)
	_current_item.is_picked_up = false
	_current_item = null
	empty = true
	on_item_dropped.emit()
	return to_return
