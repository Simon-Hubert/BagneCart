class_name RailManager extends Node2D


static var instance : RailManager	

var rails : Array[Rail]
var switchs : Array[RailSwitch]

func _init():
	if instance != null:
		print("c'est vraiment pas cool d'instancier deux fois mon singleton")
		queue_free()
	instance = self

func on_start():
	for switch in switchs:
		switch._on_switch()

func add_rail(rail: Rail):
	if rails.find(rail) == -1:
		rails.append(rail)

func add_switch(switch : RailSwitch):
	if switchs.find(switch) == -1:
		switchs.append(switch)
		switch._on_switch_signal.connect(_reset_align)

func _reset_align():
	for rail in rails:
		rail.is_aligned = false