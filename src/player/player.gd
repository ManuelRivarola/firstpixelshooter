extends CharacterBody3D

class_name Player
	
const MOVE_SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MAX_HP = 10

@onready var head := $Head
@onready var camera := $Head/Camera3D
@onready var weapon: Weapon = $Head/Camera3D/Hand.get_child(0)
@onready var target_cast: RayCast3D = $Head/Camera3D/CrosshairCast
@onready var interactables_cast: RayCast3D = $Head/Camera3D/InteractablesCast

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var hp = MAX_HP
var looking_at_interactable = false
var move_speed = MOVE_SPEED
var WEAPON_NAMES = {
	1: "Dagger",
	2: "Wand"
}

signal move_speed_changed(previous_speed: float, current_speed: float)
signal health_changed(new_health)
signal damage_received(damage: int, type: String)
signal inventory_activated
signal looking_at_item(item_name)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	PlayerInventory.item_used.connect(_on_item_used)
	var weapons = $Head/Camera3D/Hand.get_children()
	for w in weapons:
		w.user = self
		w.raycast = target_cast
		w.active = false
	weapon.active = true

func _input(event: InputEvent) -> void:
	var current_mouse_mode = Input.mouse_mode
	if event.is_action_pressed("attack") and current_mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if weapon.active:
			$MovementSpeedTimer.start()
			change_move_speed(weapon.attack_move_speed_change)
			weapon.attack()

	if event.is_action_pressed("use") and current_mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var interactable = interactables_cast.get_collider()
		if interactable == null:
			return
		if interactable.is_in_group("interactables"):
			interactable.use(self, global_position)
			emit_signal("looking_at_item", interactable.get_interactable_name())

	if event.is_action_pressed("weapon_slot_1"):
		switch_weapon(WEAPON_NAMES[1])

	if event.is_action_pressed("weapon_slot_2"):
		switch_weapon(WEAPON_NAMES[2])

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			head.rotate_y(-event.relative.x * 0.01)
			camera.rotate_x(-event.relative.y * 0.01)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

	if event.is_action_pressed("inventory"):
		if current_mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		emit_signal("inventory_activated")

	if event.is_action_pressed("reload"):
		weapon.reload()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

	move_and_slide()
	
	# Handle ItemsCast
	var interactable = interactables_cast.get_collider()
	if interactable:
		if not looking_at_interactable:
			looking_at_interactable = true
			emit_signal("looking_at_item", interactable.get_interactable_name())
	elif looking_at_interactable:
		looking_at_interactable = false
		emit_signal("looking_at_item", "")

func receive_hit(damage: float, _hit_position: Vector3) -> void:
	print("Hit Received!")
	hp -= damage
	emit_signal("health_changed", hp)
	emit_signal("damage_received", damage, "")
	print("Hit! Current HP: ", hp)

func pickup_item(item: ItemDrop):
	var added = PlayerInventory.add_item(item.item_name, 1)
	if added:
		item.queue_free()

func heal(amount: int):
	print("Healing ", amount)
	hp += amount
	if hp > MAX_HP:
		hp = MAX_HP
	emit_signal("health_changed", hp)

func _on_item_used(item_name: String, _target: String):
	var item = PlayerInventory.item_dictionary[item_name]
	if item == null:
		return
	print("Using Item: ", item["name"])
	
	var duration = item["duration"] if item.has("duration") else -1
	if item.has("heal"):
		heal(item["heal"])
	

func change_move_speed(change = -0.5):
	move_speed += change

func reset_move_speed():
	move_speed = MOVE_SPEED

func add_weapon(new_weapon: Weapon):
	var weapons = $Head/Camera3D/Hand.get_children()
	for w in weapons:
		if new_weapon.name == w.name:
			print("Error! Ya existe arma con nombre: ", new_weapon.name)
			return
			
			
	new_weapon.user = self
	new_weapon.raycast = target_cast
	$Head/Camera3D/Hand.add_child(new_weapon)

func switch_weapon(next_weapon_name: String):
	var weapons = $Head/Camera3D/Hand.get_children()
	var next_weapon = null
	
	if weapon.name == next_weapon_name:
		return
	for w in weapons:
		if next_weapon_name == w.name:
			next_weapon = w
			break
	if next_weapon == null:
		print("Error! No se encontro arma con nombre: ", next_weapon_name)
		return
	
	weapon.put_away()
	weapon.visible = false
	weapon = next_weapon
	weapon.visible = true
	weapon.hold()


func _on_movement_speed_timer_timeout():
	change_move_speed(weapon.attack_move_speed_change)


func _on_potion_timer_timeout():
	if $MovementSpeedTimer.is_stopped():
		reset_move_speed()
