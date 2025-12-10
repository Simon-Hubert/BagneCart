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
	for rail in neighbors:
		rail.disconnect_rail(self)
	var v = connections.next()
	connect_rail(neighbors[v.x])
	connect_rail(neighbors[v.y])
	propagate_orientation(dir)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Attack"):
		_on_switch()

class Connexion :
	var i : int = 0
	var j : int = 0
	var size: int = 0

	func current() -> Vector2i:
		return Vector2i(i,j)

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
