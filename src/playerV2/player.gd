extends CharacterBody3D

class_name Player

@onready var head := $Head
@onready var camera := $Head/Camera3D
@onready var active_weapon: Weapon = $Head/Camera3D/Hand.get_child(0)
@onready var interactables_ray := $Head/Camera3D/InteractablesRay
@onready var crosshair_ray := $Head/Camera3D/CrosshairRay

var looking_at_interactable = false
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var MOVE_SPEED = 4.0
var JUMP_VELOCITY = 4.5
var move_speed = MOVE_SPEED
var MAX_HP = 10
var current_hp = MAX_HP
var WEAPON_NAMES = {
	1: "Dagger",
	2: "Wand"
}

signal move_speed_changed(previous_speed: float, current_speed: float)
signal health_changed(new_health)
signal damage_received(damage: int, msg: Dictionary)
signal inventory_activated
signal looking_at_item(item_name)


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	PlayerInventory.item_used.connect(_on_item_used)
	var weapons = $Head/Camera3D/Hand.get_children()
	for wpn in weapons:
		wpn.initialize(crosshair_ray, self, false)
	active_weapon.active = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var mouse_mode = Input.get_mouse_mode()
	
	if mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
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
	
	var interactable = interactables_ray.get_collider()
	if interactable:
		if not looking_at_interactable:
			looking_at_interactable = true
			emit_signal("looking_at_item", interactable.get_interactable_name())
	elif looking_at_interactable:
		looking_at_interactable = false
		emit_signal("looking_at_item", "")

func _input(event):
	var mouse_mode = Input.get_mouse_mode()
	if mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Player está activo
		if event is InputEventMouseMotion:
			head.rotate_y(-event.relative.x * 0.01)
			camera.rotate_x(-event.relative.y * 0.01)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))
		
		if event.is_action_pressed("inventory"):
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED
			emit_signal("inventory_activated")
		
		if event.is_action_pressed("reload"):
			active_weapon.reload()
			
		if event.is_action_pressed("attack"):
			active_weapon.attack()
		
		if event.is_action_pressed("weapon_slot_1"):
			switch_weapon(WEAPON_NAMES[1])

		if event.is_action_pressed("weapon_slot_2"):
			switch_weapon(WEAPON_NAMES[2])
		
		if event.is_action_pressed("use") and looking_at_interactable:
			var interactable = interactables_ray.get_collider()
			if interactable == null:
				return
			if interactable.is_in_group("interactables"):
				interactable.use(self, global_position)
				emit_signal("looking_at_item", interactable.get_interactable_name())
	
	if mouse_mode == Input.MOUSE_MODE_CONFINED:
		if event.is_action_pressed("inventory"):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			emit_signal("inventory_activated")

func _on_item_used(item_name: String, _target: String):
	var item = ItemIndex.get_item(item_name)
	if item == null:
		return
	if item.has("heal"):
		heal(item["heal"])

func heal(amount: int):
	current_hp += amount
	if current_hp > MAX_HP:
		current_hp = MAX_HP
	emit_signal("health_changed", current_hp)

func switch_weapon(next_weapon_name: String):
	var weapons = $Head/Camera3D/Hand.get_children()
	var next_weapon = null
	
	if active_weapon.name == next_weapon_name:
		return
	for w in weapons:
		if next_weapon_name == w.name:
			next_weapon = w
			break
	if next_weapon == null:
		print("Error! No se encontro arma con nombre: ", next_weapon_name)
		return
	
	active_weapon.put_away()
	active_weapon.visible = false
	active_weapon = next_weapon
	active_weapon.visible = true
	active_weapon.hold()

func pickup_item(item: ItemDrop):
	var added = PlayerInventory.add_item(item.item_name, 1)
	if added:
		item.queue_free()

func set_move_speed(new_move_speed := -1.0):
	if new_move_speed == -1.0:
		move_speed = MOVE_SPEED
	else:
		move_speed = new_move_speed

func receive_hit(damage: float, _hit_position: Vector3, msg = {}) -> void:
	current_hp -= damage
	emit_signal("health_changed", current_hp)
	emit_signal("damage_received", damage, msg)
