class_name SwitchInteraction extends Interactable

@export var switch : RailSwitch

func interact(_player: Player):
	switch._on_switch()
