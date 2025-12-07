class_name RailSwitch extends Interactable

@export_group("GD")
@export var default_switched := false
@export_group("GP")
@export var horizontal := true
@export var default_region_coordinates : Vector2
@export var other_region_coordinates : Vector2
@export var rail : Rail
@export var sprite : Sprite2D
var switched := false

func _ready():
	if default_switched :
		interact(null)

func interact(_player: Player):	
	print("interacted with switch")
	sprite.region_rect.position = other_region_coordinates if(not switched) else default_region_coordinates
	rail.dir = Vector2(-rail.dir.x, rail.dir.y) if horizontal else Vector2(rail.dir.x, -rail.dir.y)
	rail.flip_normal = not rail.flip_normal
	switched = not switched
