extends StateMachine


func _on_skull_damage_received(damage, hit_position, msg):
	state.receive_damage(damage, hit_position, msg)


func _on_skull_allegiance_changed(new_allegiance):
	transition_to("Idle", {})
