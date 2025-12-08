class_name timer extends Control

@onready var timer_label : Label = $Timer
@onready var quest_timer : Timer = $QuestTimer

@export var base_timer : float = 30
@export var distance_to_timer_modifier : float = 0.01

var _is_timer_active : bool = false

func _ready() -> void:
	quest_manager.Instance.on_quest_finished.connect(_on_quest_finished)
	quest_manager.Instance.on_quest_recieved.connect(_on_new_quest)
	timer_label.visible = false
	
##Update the label
func _process(_delta: float) -> void:
	if !_is_timer_active:
		return
	timer_label.text = String.num(quest_timer.time_left, 0)

##Stop the timer if the quest is finished
func _on_quest_finished() -> void:
	_is_timer_active = false
	timer_label.visible = false
	quest_timer.stop()

##Start the timer when accept a quest
func _on_new_quest() -> void:
	_is_timer_active = true
	timer_label.visible = true
	quest_timer.wait_time = base_timer + distance_to_timer_modifier * quest_manager.Instance.get_nearest_item()
	quest_timer.start()

##Event that plays when the timer is finished
func _on_quest_timer_finished() -> void:
	_is_timer_active = false
	timer_label.visible = false
	game_manager.Instance.failed_quest()
