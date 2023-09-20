extends MobState

var target: Node3D
var nav_agent_enabled = false

func enter(msg = {}):
	target = null
	if msg.has("target"):
		target = msg["target"]
	if target == null or mob.global_position.distance_to(target.global_position) > 10:
		state_machine.transition_to("Idle", {})
	nav_agent_enabled = true
	$UpdateTimer.start(randf_range(0.0, 0.0125))
	update_target_location()

func physics_update(delta):
	mob.look_at(target.global_position)

	var current_agent_position: Vector3 = mob.global_position
	var next_path_position: Vector3 = state_machine.navigation_agent.get_next_path_position()
	var target_position: Vector3 = state_machine.navigation_agent.get_final_position()
	
	var new_velocity: Vector3 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * mob.speed * delta
	
	if state_machine.navigation_agent.avoidance_enabled:
		state_machine.navigation_agent.set_velocity(new_velocity)
	else:
		_on_navigation_agent_3d_velocity_computed(new_velocity)
	
func update_target_location():
	if target == null:
		state_machine.transition_to("Idle", {})
	state_machine.navigation_agent.set_target_position(target.global_position)

func exit():
	nav_agent_enabled = false
	mob.velocity = Vector3.ZERO
	mob.move_and_slide()

func _on_navigation_agent_3d_target_reached():
	if state_machine.state.name != self.name:
		return
	nav_agent_enabled = false
	state_machine.transition_to("Attack", {"target": target})


func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	if state_machine.state.name != self.name:
		return
	if not nav_agent_enabled:
		return
	mob.velocity = safe_velocity
	mob.move_and_slide()


func _on_update_timer_timeout():
	if state_machine.state.name != self.name:
		return
	$UpdateTimer.start(randf_range(0, 0.125))
	update_target_location()
