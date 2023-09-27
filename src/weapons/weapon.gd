extends Node3D

class_name Weapon

@export var damage: int
@export var attack_move_speed_change: float = -0.5
var raycast: RayCast3D
var user: Node3D
var active = false

signal attacking

func initialize(
	raycast_: RayCast3D = null, 
	user_: Node3D = null, 
	active_: bool = false
	):
	raycast = raycast_
	user = user_
	active = active_

func attack():
	pass

func put_away():
	pass

func hold():
	pass

func reload():
	pass
