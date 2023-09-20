extends Mob

func damage_animation():
	var tween = get_tree().create_tween()
	var material: BaseMaterial3D = $Body.get_surface_override_material(0)
	tween.set_loops(2)
	tween.tween_property(material, "albedo_color", Color.RED, 0.2)
	tween.tween_property(material, "albedo_color", Color.WHITE, 0.2)

func receive_hit(damage, hit_position, msg = {}):
	health -= damage
	if health <= 0:
		die(msg)
	else:
		damage_animation()
	emit_signal("damage_received", damage, hit_position, msg)

func die(msg) -> void:
	if get_parent() == null:
		return
		
	var corpse: Node3D = corpse_scene.instantiate()
	corpse.global_transform = global_transform
	get_parent().add_child(corpse)

	if msg.has("weapon") and msg["weapon"] == "Bone Dagger":
		add_item("Skull Essence", 1)

	for drop in item_drops:
		get_parent().add_child(drop)
		drop.drop()
		drop.global_position = global_position

	queue_free()
