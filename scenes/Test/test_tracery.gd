extends Node2D

func _ready() -> void:
	var newGrammarDico : Dictionary = TraceryLoader.create_grammar_dictionary("res://resources/Json/TestJson.json")
	var newGrammar : Tracery.Grammar = TraceryLoader.create_grammar(newGrammarDico)
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
