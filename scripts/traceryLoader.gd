class_name TraceryLoader extends RefCounted

##create a grammar dictionary from a json file
static func create_grammar_dictionary(path : String) -> Dictionary:	
	var grammarData = _get_json_from_file(path)	
	#Populate the grammar dictionary from json data	
	var grammar_dictionary = Dictionary()
	for categories in grammarData :
		grammar_dictionary[categories] = grammarData.get(categories)
		
	return grammar_dictionary


##Returns a Tracery grammar based on a dictionary
static func create_grammar(dictionary : Dictionary) -> Tracery.Grammar:
	#Create new grammar from dictionary
	var new_grammar = Tracery.Grammar.new( dictionary )
	new_grammar.rng = RandomNumberGenerator.new()
	return new_grammar


##Returns a sentance based on the dictionary
##This override create a grammar by default and should be used for spare sentence generation
##origin state the beginning of the sentence construction
##If "origin" isn't override, it defaults to "origin" (logic)
##If sevral "origin"s have been defined, use "index" to specify one of them
static func getSentenceFromGrammarDictionary(dictionary : Dictionary, origin : String = "origin" , index : int = -1) -> String:
	if !dictionary:
		push_error("dictionary is null")
		return ""
		
	#Create new grammar from dictionary
	var rng = RandomNumberGenerator.new()
	var new_grammar = create_grammar(dictionary)
	
	#Get a (random) index from the origin
	var baseIndex : int = index;
	if baseIndex <= -1:
		baseIndex = rng.randi() % dictionary[origin].size()
	return new_grammar.flatten(dictionary[origin][baseIndex])


##Returns a sentance based on the dictionary
##This override doesn't create a grammar by default and should be used when sorting a lot of times
##origin state the beginning of the sentence construction
##If "origin" isn't override, it defaults to "origin" (logic)
##If sevral "origin"s have been defined, use "index" to specify one of them
static func getSentenceFromGrammar(dictionary : Dictionary, grammar : Tracery.Grammar, origin : String = "origin" , index : int = -1) -> String:
	if !dictionary:
		push_error("dictionary is null")
		return ""
	if !dictionary.has(origin):
		push_error("dictionary doesn't have : " + origin)
		return ""
		
	#Get a (random) index from the origin
	var baseIndex : int = index;
	if baseIndex <= -1:
		baseIndex = grammar.rng.randi() % dictionary[origin].size()
	return grammar.flatten(dictionary[origin][baseIndex])

##Save a key / value data to a grammar
static func save_data_in_grammar(grammar : Tracery.Grammar, key : String, value : String):
	grammar.set_save_data(key, value)

##load a json file
static func _get_json_from_file(path : String) -> Dictionary: 
	var file = FileAccess.open(path, FileAccess.READ)
	if !file:
		push_error("Cannot open file at path : " + path)
		return {}
	var content = file.get_as_text()
	var data = JSON.parse_string(content)
	if data == null:
		push_error("Cannot open file at path : " + path)
		return {}
	return data
