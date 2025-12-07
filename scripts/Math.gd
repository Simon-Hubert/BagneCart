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
        