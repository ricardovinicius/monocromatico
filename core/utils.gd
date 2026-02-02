class_name Utils
extends Object

static func generate_uuid(prefix: String = "", _seed: int = 0) -> String:
    var rng = RandomNumberGenerator.new()
    rng.seed = _seed
    return "{0}-{1}-{2}-{3}-{4}".format([prefix, rng.randi_range(0, 1000000), rng.randi_range(0, 1000000), rng.randi_range(0, 1000000), rng.randi_range(0, 1000000)])