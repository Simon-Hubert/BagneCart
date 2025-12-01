extends Node2D

func _ready() -> void:
	var newGrammarDico : Dictionary = TraceryLoader.createGrammarDictionary("res://resources/Json/TestJson.json")
	var newGrammar : Tracery.Grammar = TraceryLoader.CreateGrammar(newGrammarDico)
	print(TraceryLoader.getSentenceFromGrammar(newGrammarDico, newGrammar))
	print(TraceryLoader.getSentenceFromGrammar(newGrammarDico, newGrammar))
	print(TraceryLoader.getSentenceFromGrammar(newGrammarDico, newGrammar))
	print(TraceryLoader.getSentenceFromGrammar(newGrammarDico, newGrammar))
	print(TraceryLoader.getSentenceFromGrammar(newGrammarDico, newGrammar))
	print(TraceryLoader.getSentenceFromGrammar(newGrammarDico, newGrammar))
	print(TraceryLoader.getSentenceFromGrammar(newGrammarDico, newGrammar))
	print(TraceryLoader.getSentenceFromGrammar(newGrammarDico, newGrammar))
	print(TraceryLoader.getSentenceFromGrammar(newGrammarDico, newGrammar))
	print(TraceryLoader.getSentenceFromGrammar(newGrammarDico, newGrammar))
