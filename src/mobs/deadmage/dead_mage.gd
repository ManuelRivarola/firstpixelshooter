extends Mob

func _ready():
	pass

func damage_animation():
	var tween = get_tree().create_tween()
	var material: BaseMaterial3D = $Body.get_surface_override_material(0)
	tween.set_loops(2)
	tween.tween_property(material, "albedo_color", Color.RED, 0.2)
	tween.tween_property(material, "albedo_color", Color.WHITE, 0.2)

func receive_hit(damage, hit_position, _msg = {}):
	health -= damage
	if health <= 0:
		die()
	else:
		damage_animation()
	emit_signal("damage_received", damage, hit_position)

func die() -> void:
	if get_parent() != null:
		var corpse: Node3D = corpse_scene.instantiate()
		corpse.global_transform = global_transform
		get_parent().add_child(corpse)
		
		for drop in item_drops:
			get_parent().add_child(drop)
			drop.drop()
			drop.global_position = global_position
	queue_free()
