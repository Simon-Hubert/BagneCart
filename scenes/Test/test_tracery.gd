extends Node2D

func _ready() -> void:
	var categories = ["name", "occupation", "origin"]
	var newGrammar = TraceryLoader.createGrammarDictionary("res://resources/Json/TestJson.json", categories)
	print(TraceryLoader.getSentenceFromGrammar(newGrammar, "origin"))	
