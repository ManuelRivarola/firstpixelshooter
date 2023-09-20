extends MobState

func enter(_msg := {}):
	state_machine.animation_player.play("idle")

func physics_update(_delta):
	var target = state_machine.vision.cast()
	if target is Player:
		state_machine.transition_to("Chase", {"target": target})

func receive_damage(_damage, hit_position):
	mob.look_at(hit_position)
