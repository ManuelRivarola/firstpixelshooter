extends Weapon

@onready var animation_player = $AnimationPlayer
@onready var charged_player = $ChargedPlayer

var charged = false

func attack():
	if active:
		active = false
		var current_move_speed = user.move_speed
		$MoveSpeedTimer.start()
		user.set_move_speed(current_move_speed * 0.6)
		$AnimationPlayer.play("attack")

func _on_attack_area_body_entered(body):
	if body.has_method("receive_hit"):
		var dmg = damage if not charged else damage * 3
		body.receive_hit(
			dmg, 
			user.global_position, 
			{
				"weapon": "Bone Dagger", 
				"charged": charged, 
				"dmg_type": "physical"
			}
		)
		uncharge()
		$Hit.play()

func reload():
	if PlayerInventory.has_item("Skull Essence") and not charged:
		PlayerInventory.use_item("Skull Essence")
		charge()

func charge():
	charged_player.play("charged")
	charged = true
	$ChargedTimer.start()

func uncharge():
	charged = false
	charged_player.stop()

func put_away():
	animation_player.play("RESET")
	animation_player.play("put_away")

func hold():
	animation_player.play("RESET")
	animation_player.play_backwards("put_away")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "attack":
		active = true
	if anim_name == "hold":
		active = true
	if anim_name == "put_away":
		active = !active


func _on_charged_timer_timeout():
	uncharge()


func _on_move_speed_timer_timeout():
	user.set_move_speed()
