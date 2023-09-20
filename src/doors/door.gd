extends Node3D

@export var locked: bool = false
@export var key: String
@onready var animation_player = $AnimationPlayer

var open = false

func use(user: Node3D, from: Vector3):
	if locked:
		if PlayerInventory.has_item(key):
			locked = false
		else:
			print("Door Locked. Requires ", key)
	if not locked:
		var z_vector = global_transform.basis.z
		var relative_pos = user.global_transform.origin - global_transform.origin
		var dot = z_vector.dot(relative_pos)
		
		var angle
		if open :
			angle = 0
		else:
			angle = 90 if dot > 0 else -90
		var tween = get_tree().create_tween()
		tween.tween_property($Hinge, "rotation", Vector3(0, deg_to_rad(angle), 0), 1)
		open = not open
