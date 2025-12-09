class_name math

static func exponential_decay(a, b, decay: float, delta: float):
	return b + (a-b) * exp(-decay*delta)

static func cubic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var q2 = p2.lerp(p3, t)

	var r0 = q0.lerp(q1, t)
	var r1 = q1.lerp(q2, t)

	var s = r0.lerp(r1, t)
	return s


static func vector_iterator(i: int) -> Vector2:
	match i%4:
		0:return Vector2(1,0)
		1:return Vector2(0,1)
		2:return Vector2(-1,0)
		3:return Vector2(0,1)
		_:return Vector2(0,0)

static func clamp_cart_pos(cart: Cart, rail: Rail) -> void:
	if rail == null: return
	if not rail.is_end_of_line: return
	var a = rail.dir

	if a.dot(Vector2.UP) > 0.01 :
		if cart.global_position.y > rail.global_position.y:
			cart.global_position.y = rail.global_position.y
		return
	if a.dot(Vector2.DOWN) > 0.01:
		if cart.global_position.y < rail.global_position.y:
			cart.global_position.y = rail.global_position.y
		return
	if a.dot(Vector2.LEFT) > 0.01:
		if cart.global_position.x > rail.global_position.x:
			cart.global_position.x = rail.global_position.x
		return
	if a.dot(Vector2.RIGHT) > 0.01:
		if cart.global_position.x < rail.global_position.x:
			cart.global_position.x = rail.global_position.x
		return
		
