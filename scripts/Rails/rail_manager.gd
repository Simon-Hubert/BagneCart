class_name RailManager extends Node2D


@export var rail0 : Rail
@export var rail1 : Rail
@export var rail2 : Rail

func _ready():
    rail0.connect_rail(rail1)
    rail1.connect_rail(rail2)