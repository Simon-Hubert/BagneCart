class_name TraceryLoader extends RefCounted

##create a grammar dictionary from a json file
static func createGrammarDictionary(path : String) -> Dictionary:	
	var grammarData = _get_json_from_file(path)	
	#Populate the grammar dictionary from json data	
	var grammar_dictionary = Dictionary()
	for categories in grammarData :
		grammar_dictionary[categories] = grammarData.get(categories)
		
	return grammar_dictionary



##Returns a sentance based on the dictionary
##origin state the beginning of the sentence construction
##If "origin" isn't override, it defaults to "origin" (logic)
##If sevral "origins" have been defined, use "index" to specify one of them
static func getSentenceFromGrammarDictionary(dictionary : Dictionary, origin : String = "origin" , index : int = -1) -> String:
	if !dictionary:
		push_error("dictionary is null")
		
	#Create new grammar from dictionary
	var new_grammar = Tracery.Grammar.new( dictionary )
	var rng =  RandomNumberGenerator.new()
	new_grammar.rng = rng
	new_grammar.add_modifiers(Tracery.UniversalModifiers.get_modifiers())
	
	var baseIndex : int = index;
	if baseIndex <= -1:
		baseIndex = rng.randi_range(0, dictionary[origin].size() - 1)
	return new_grammar.flatten(dictionary[origin][baseIndex])



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
