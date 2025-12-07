class_name Interactable extends Area2D

@export var interaction_priority : int
var can_fail := false

func interact(_player: Player): pass

func try_interact(_player: Player) -> bool :
    return true