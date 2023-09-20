extends Node3D

class_name Weapon

@export var damage: int
@export var attack_move_speed_change: float = -0.5
var raycast: RayCast3D
var user: Node3D
var active = false

signal attacking

func attack():
	pass

func put_away():
	pass

func hold():
	pass

func reload():
	pass
