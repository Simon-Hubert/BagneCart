class_name RailSwitch extends Rail
var switch_lever : lever_interaction
var neighbors : Array[Rail]
var connections: Connexion

func connect_rail(to_connect :Rail):
	super(to_connect)
	if neighbors.find(to_connect) == -1:
		neighbors.append(to_connect)
		connections.size = neighbors.size()

func _ready():
	if switch_lever != null:
		switch_lever.player_interact.connect(_on_switch)
	connections = Connexion.new()
	

func _on_switch():
	var v = connections.next()
	init_rail(neighbors[v.x], neighbors[v.y])
	propagate_orientation(dir)


class Connexion :
	var i : int = 0
	var j : int = 0
	var size: int = 0

	func next() -> Vector2i:

		j += 1
		if j >= i:
			j = 0
			i += 1
		if i >= size:
			i = 0
		
		if i!=j:
			return Vector2i(i,j)
		else: 
			return next()
