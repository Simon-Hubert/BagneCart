class_name timer extends Control

@onready var timer_label : Label = $Timer
@onready var quest_timer : Timer = $QuestTimer

@export var base_timer : float = 30
@export var distance_to_timer_modifier : float = 0.01

@export_category("Visual")
@export var timer_gradiant : Gradient

var _is_timer_active : bool = false
var _time_set : float = 0

func _ready() -> void:
	quest_manager.Instance.on_quest_finished.connect(_on_quest_finished)
	quest_manager.Instance.on_quest_recieved.connect(_on_new_quest)
	timer_label.visible = false
	
##Update the label
func _process(_delta: float) -> void:
	if !_is_timer_active:
		return
	timer_label.text = String.num(quest_timer.time_left, 0)
	timer_label.add_theme_color_override("font_color", timer_gradiant.sample(0.0 if _time_set == 0.0 else quest_timer.time_left / _time_set))

##Stop the timer if the quest is finished
func _on_quest_finished() -> void:
	_is_timer_active = false
	timer_label.visible = false
	quest_timer.stop()

##Start the timer when accept a quest
func _on_new_quest() -> void:
	_is_timer_active = true
	timer_label.visible = true
	_time_set = base_timer + distance_to_timer_modifier * quest_manager.Instance.get_nearest_item()
	quest_timer.wait_time = _time_set
	quest_timer.start()

##Event that plays when the timer is finished
func _on_quest_timer_finished() -> void:
	_is_timer_active = false
	timer_label.visible = false
	game_manager.Instance.failed_quest()
