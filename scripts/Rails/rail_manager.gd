class_name RailManager extends Node2D


@export var up_rail : Rail
@export var down_rail : Rail
@export var left_rail : Rail
@export var right_rail : Rail
@export var switch : RailSwitch

func _ready():
	##switch.connect_rail(up_rail)
	switch.connect_rail(down_rail)
	switch.connect_rail(left_rail)
	switch.connect_rail(right_rail)

func _process(delta):
	if Input.is_action_just_pressed("Attack"):
		switch._on_switch()
