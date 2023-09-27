extends MobState

@export var attack_area: Area3D

var target: Node3D

func enter(msg = {}):
	if msg.has("target"):
		target = msg["target"]
	mob.velocity = Vector3.ZERO
	state_machine.animation_player.play("attack_windup")

func physics_update(_delta):
	if state_machine.animation_player.assigned_animation != "attack_windup":
		return
	if target != null:
		mob.look_at(target.global_position)

func hit():
	mob.velocity = Vector3.ZERO
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("receive_hit"):
			body.receive_hit(mob.damage, mob.global_position, {"dmg_type": "physical"})


func _on_animation_player_animation_finished(anim_name):
	if state_machine.state.name != self.name:
		return
	if anim_name == "attack_windup":
		state_machine.animation_player.play("attack")
	if anim_name == "full_attack" or anim_name == "attack":
		state_machine.transition_to("Chase", {"target": target})
