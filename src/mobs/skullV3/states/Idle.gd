extends MobState

var turning_at_target = false
var target_position: Vector3

func enter(_msg := {}):
	turning_at_target = false
	state_machine.animation_player.play("idle")

func physics_update(delta):
	if not turning_at_target:
		return
	mob.rotate_towards(target_position, delta)

func receive_damage(_damage, hit_position, msg):
	turning_at_target = true
	target_position = hit_position

func exit():
	turning_at_target = false

func _on_vision_body_detected(body):
	if state_machine.state.name == self.name:
		state_machine.transition_to("Chase", {"target": body})


func _on_proximity_body_entered(body):
	for group in mob.target_groups:
		if body.is_in_group(group):
			print("Entered!")
			turning_at_target = true
			target_position = body.global_position
			return
