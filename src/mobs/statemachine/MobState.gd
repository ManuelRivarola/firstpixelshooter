class_name MobState
extends State

var mob: Mob


func _ready() -> void:
	# The states are children of the `Player` node so their `_ready()` callback will execute first.
	# That's why we wait for the `owner` to be ready first.
	await owner.ready
	# The `as` keyword casts the `owner` variable to the `Player` type.
	# If the `owner` is not a `Player`, we'll get `null`.
	mob = owner as Mob
	# This check will tell us if we inadvertently assign a derived state script
	# in a scene other than `Player.tscn`, which would be unintended. This can
	# help prevent some bugs that are difficult to understand.
	assert(mob != null)

func receive_damage(damage: float, hit_position: Vector3, msg: Dictionary):
	pass
