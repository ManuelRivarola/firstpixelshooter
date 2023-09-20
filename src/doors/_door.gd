extends StaticBody3D
var interactable_name = "Door"

func use(user: Node3D, from: Vector3):
	get_parent().get_parent().use(user, from)
	
func get_interactable_name():
	var root = get_parent().get_parent()
	if root.locked:
		return "Locked. Requires " + root.key
	else:
		return interactable_name
