extends StateMachine


func _on_dead_mage_damage_received(damage, hit_position):
	state.receive_damage(damage, hit_position)
