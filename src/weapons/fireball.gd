extends Area3D

@export var SPEED = 25.0
@export var DAMAGE = 3

var user: Node3D
var move_direction = Vector3.ZERO
var origin_position: Vector3

func _ready():
	#res://assets/sfx/fire-magic-6947.mp3
	set_physics_process(false)

func _physics_process(delta):
	var velocity = move_direction * SPEED
	global_position += velocity * delta

func _on_timer_timeout():
	queue_free()

func spawn(origin: Vector3, target_position: Vector3, user: Node3D):
	self.user = user
	
	GlobalLevel.level_root.add_child(self)
	origin_position = origin
	global_position = origin
	move_direction = global_position.direction_to(target_position)
	
	set_physics_process(true)



func _on_body_entered(body):
	if body.has_method("receive_hit"):
		body.receive_hit(DAMAGE, origin_position, {})
	set_physics_process(false)
	$AnimationPlayer.play("explode")
	await $AnimationPlayer.animation_finished
	queue_free()
