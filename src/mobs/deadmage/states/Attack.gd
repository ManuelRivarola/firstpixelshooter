extends MobState

@export var fireball_scene: PackedScene
@export var fireball_origin: Node3D
var target: Node3D = null

func enter(_msg = {}):
	if not _msg.has("target"):
		print("Error! No target to attack")
		state_machine.transition_to("Idle", {})
	else:
		target = _msg["target"]
		state_machine.animation_player.play("attack")
		await state_machine.animation_player.animation_finished
		state_machine.transition_to("Chase", {"target": target})

func cast_fireball():
	var fireball: Area3D = fireball_scene.instantiate()
	fireball.spawn(fireball_origin.global_position, target.global_position, mob)
