extends Area3D

@onready var ray: RayCast3D = $RayCast3D

var target_groups = ["player"]
var target = null

signal body_detected(body: Node3D)

func cast():
	return target

func _physics_process(delta):
	pass

func _on_timer_timeout():
	# Bug de Godot: Para detectar cuerpos que ya se encuentren dentro del área
	# hay que forzar un update cambiando la mask
	var prev_mask = collision_mask
	collision_mask = 0
	collision_mask = prev_mask
	for body in get_overlapping_bodies():
		var groups = body.get_groups()
		for group in groups:
			if target_groups.has(group):
				ray.target_position = ray.to_local(body.global_position) * 1.5
				ray.force_raycast_update()
				target = ray.get_collider()
				emit_signal("body_detected", target)
				return


func _on_skull_allegiance_changed(new_allegiance):
	target_groups = GlobalLevel.TARGET_GROUPS[new_allegiance]
	target = null
