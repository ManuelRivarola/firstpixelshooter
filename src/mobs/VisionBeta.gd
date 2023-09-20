extends Area3D

var angle_cone_of_vision: float = deg_to_rad(30.0)
var max_view_distance: float = 300
var angle_between_rays: float = deg_to_rad(2.5)
var casting_rays: bool = false

func _ready():
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body is Player:
			casting_rays = true
			break
	generate_raycasts()

func enable_raycasts(enable := true):
	var rays = $Rays.get_children()
	casting_rays = enable
	for ray in rays:
		ray.enabled = enable

func generate_raycasts() -> void:
	var ray_count: int = int(angle_cone_of_vision / angle_between_rays)
	for i in ray_count:
		var angle_h = angle_between_rays * (i - ray_count / 2.0)
		var target_position_base = Vector3.FORWARD.rotated(Vector3.UP, angle_h)
		for j in ray_count:
			var angle_v = angle_between_rays * (j - ray_count / 2.0)
			var target_position = target_position_base.rotated(Vector3.RIGHT, angle_v)
			var ray: RayCast3D = RayCast3D.new()
			ray.enabled = casting_rays
			ray.target_position = target_position * max_view_distance
			ray.collision_mask = 0b00000000_00000000_00000000_00000011
			$Rays.add_child(ray)

func cast():
	if !casting_rays:
		return null
		
	var target = null
	var rays = $Rays.get_children()
	for ray in rays:
		target = ray.get_collider()
		if target is Player:
			break
		else:
			target = null
	print(target)
	return target
	
func _on_body_entered(body):
	if body is Player:
		enable_raycasts(true)


func _on_body_exited(body):
	if body is Player:
		enable_raycasts(false)
