class_name TraceryLoader extends RefCounted

##create a grammar dictionary from a json file, with the categories
static func createGrammarDictionary(path : String, categories : PackedStringArray) -> Dictionary:
	if categories.is_empty():
		push_error("No categories entered")
		
	var grammarData = _get_json_from_file(path)	
	#Populate the grammar dictionary from json data	
	var grammar_dictionary = Dictionary()
	for cat in categories:
		grammar_dictionary[cat] = grammarData.get(cat)
		
	return grammar_dictionary



##Returns a sentance based on the dictionary
##origin state the beginning of the sentence construction
##If sevral "origins" have been defined, use "index" to cycle through it
static func getSentenceFromGrammar(_dictionary : Dictionary, origin : String, index : int = 0) -> String:
	if !_dictionary:
		push_error("dictionary is null")
	if !_dictionary.find_key(origin):
		push_error("Origin " + origin + " doesn't correspond to any key in the dictionnary")
		
	#Create new grammar from dictionary
	var new_grammar = Tracery.Grammar.new( _dictionary )
	new_grammar.rng = RandomNumberGenerator.new()
	new_grammar.add_modifiers(Tracery.UniversalModifiers.get_modifiers())
	return new_grammar.flatten(_dictionary[origin][index])



##load a json file
static func _get_json_from_file(path : String) -> Dictionary: 
	var file = FileAccess.open(path, FileAccess.READ)
	if !file:
		push_error("Cannot open file at path " + path)
	var content = file.get_as_text()
	var data = JSON.parse_string(content)
	if data == null:
		push_error("Loading Json at path {} failed", path)
	return data
