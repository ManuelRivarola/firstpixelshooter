extends RigidBody3D

class_name ItemDrop

@export var item_name: String

func _ready():
	if self.item_name != "":
		var mesh = ItemIndex.get_item_property(self.item_name, "mesh")
		sleeping = true
		initialize(mesh, self.item_name)

func initialize(mesh: ArrayMesh, item_name: String = "TestItem"):
	$MeshInstance3D.mesh = mesh
	$AnimationPlayer.play("float")
	self.item_name = item_name

func drop():
	var sleep_timer = Timer.new()
	add_child(sleep_timer)
	sleep_timer.timeout.connect(_on_sleep_timer_timeout)
	sleep_timer.one_shot = true
	sleep_timer.start(5)

	var drop_direction: Vector3 = Vector3(0.5, 0.5, 0.5)
	drop_direction = drop_direction.rotated(Vector3.UP, deg_to_rad(randf() * 360))
	apply_impulse(drop_direction * 3)

func use(user: Node3D, _from: Vector3):
	if user.has_method("pickup_item"):
		user.pickup_item(self)

func get_interactable_name():
	return item_name

func _on_sleep_timer_timeout():
	sleeping = true
