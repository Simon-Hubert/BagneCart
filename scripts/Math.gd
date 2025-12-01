class_name math

static func exponential_decay(a, b, decay: float, delta: float):
    return b + (a-b) * exp(-decay*delta)