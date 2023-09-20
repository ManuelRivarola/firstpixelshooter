extends CharacterBody3D

class_name Mob

@export var inventory: Array[String]
@export var HEALTH: int = 4
@export var DAMAGE: int = 1
@export var SPEED: float = 2.0
@export var allegiance: String = "Enemy"
@export var corpse_scene: PackedScene

var item_drops: Array[ItemDrop]
var speed: float
var health: int
var damage: int
var attacking: bool
var target_groups = []

signal damage_received(damage: int, hit_position: Vector3, msg: Dictionary)
signal allegiance_changed(new_allegiance: String)

func initialize() -> void:
	speed = SPEED
	health = HEALTH
	damage = DAMAGE
	# Configuramos y cargamos en memoria los items a dropear
	var item_drop_scene: PackedScene = load("res://src/items/ItemDrop.tscn")
	for item_name in inventory:
		var drop = item_drop_scene.instantiate()
		var item_mesh: ArrayMesh = ItemIndex.get_item_property(item_name, "mesh")
		drop.initialize(item_mesh, item_name)
		item_drops.append(drop)
	target_groups = GlobalLevel.TARGET_GROUPS[allegiance]
	emit_signal("allegiance_changed", allegiance)

func change_allegiance(new_allegiance: String) -> void:
	allegiance = new_allegiance
	target_groups = GlobalLevel.TARGET_GROUPS[new_allegiance]
	emit_signal("allegiance_changed", allegiance)

func add_item(item_name: String, amount: int):
	var item_drop_scene: PackedScene = load("res://src/items/ItemDrop.tscn")
	var drop = item_drop_scene.instantiate()
	var item_mesh: ArrayMesh = ItemIndex.get_item_property(item_name, "mesh")
	drop.initialize(item_mesh, item_name)
	for i in amount:
		item_drops.append(drop)

func rotate_towards(target_position: Vector3, delta: float):
	"""var current_direction = Vector2(global_transform.basis.z.x, global_transform.basis.z.z)
	var desired_direction = Vector2(target_position.x, target_position.z)
	if abs(rad_to_deg(current_direction.angle_to(desired_direction))) < 5:
		print(abs(rad_to_deg(current_direction.angle_to(desired_direction))))
		return
	var rotation_direction = 1 if current_direction.angle_to(desired_direction) > 0 else -1
	global_rotate(Vector3.UP, rotation_direction * delta * 5)"""
	var target_angle = $RotationHelper.global_position.angle_to(target_position)
	if abs(target_angle) < 1/8:
		return
	var target_direction = -1 if target_angle < 0 else 1
	global_rotate(Vector3.UP, delta * target_direction * 5)

func receive_hit(damage: int, hit_position: Vector3, msg: Dictionary = {}):
	pass

func heal(amount: int):
	pass
