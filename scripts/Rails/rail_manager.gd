class_name RailManager extends Node2D


func _process(_delta):
	if Input.is_action_just_pressed("Attack"):
		#print("TEST")
		var target := get_global_mouse_position()
		print(target)
		var space_state = get_world_2d().direct_space_state
		var point := PhysicsPointQueryParameters2D.new()
		point.collide_with_areas = true
		point.position = target
		var result = space_state.intersect_point(point)
		#print(result)
		for area in result:
			if area.collider is Rail:
				print("Name : {0}".format([area.collider]))
				print(area.collider.dir)
				print(area.collider.flip_normal)
				print("position :")
				print(area.collider.global_position)
				print("-1 :")
				print(area.collider.connected[-1].global_position)
				print("-2 :")
				print(area.collider.connected[-2].global_position)				
