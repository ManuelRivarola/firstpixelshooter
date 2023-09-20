extends MobState

var target: Node3D

func enter(msg = {}):
	if msg.has("target"):
		target = msg["target"]
	if target == null:
		state_machine.transition_to("Idle", {})
	update_target_location()
	print("Begin Chase")

func physics_update(delta):
	mob.look_at(target.global_position, Vector3.UP)

	var current_agent_position: Vector3 = mob.global_position
	var next_path_position: Vector3 = state_machine.navigation_agent.get_next_path_position()
	
	var new_velocity: Vector3 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * mob.speed * delta
	if state_machine.navigation_agent.avoidance_enabled:
		state_machine.navigation_agent.set_velocity(new_velocity)
	else:
		_on_navigation_agent_3d_velocity_computed(new_velocity)

func update_target_location():
	var spot = state_machine.vision.cast()
	if spot is Player and mob.global_position.distance_to(spot.global_position) < 12:
		state_machine.transition_to("Attack", {"target": target})
		return
	else:
		state_machine.navigation_agent.set_target_position(target.global_position)


func _on_navigation_agent_3d_target_reached():
	update_target_location()

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	mob.velocity = safe_velocity
	mob.move_and_slide()


func _on_update_timer_timeout():
	$UpdateTimer.start(0.01)
	update_target_location()

