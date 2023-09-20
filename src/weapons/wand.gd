extends Weapon

@export var fireball_scene: PackedScene
@onready var animation_player = $AnimationPlayer
@onready var attack_origin = $Mesh/AttackOrigin
@onready var essence_timer: Timer = $EssenceTimer

func _ready():
	PlayerInventory.connect("item_used", _on_PlayerInventory_item_used)
	if not PlayerInventory.has_item("Fire Essence"):
		PlayerInventory.add_item("Fire Essence", 1)

func attack():
	if active and PlayerInventory.has_item("Fire Essence"):
		PlayerInventory.use_item("Fire Essence")
		animation_player.play("attack")

func spawn_fireball():
	var fireball: Node3D = fireball_scene.instantiate()
	var target_position = raycast.get_collision_point()
	fireball.spawn(attack_origin.global_position, target_position, user)

func play_sound():
	$AudioStreamPlayer.play()

func put_away():
	animation_player.play("put_away")

func hold():
	animation_player.play("RESET")
	animation_player.play_backwards("put_away")

func _on_PlayerInventory_item_used(item_name: String, user: String):
	if item_name == "Fire Essence" and not PlayerInventory.has_item("Fire Essence"):
		essence_timer.start()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "hold":
		active = true
	if anim_name == "put_away":
		active = !active


func _on_essence_timer_timeout():
	if not PlayerInventory.has_item("Fire Essence"):
		PlayerInventory.add_item("Fire Essence", 1)
