extends Node3D

class_name Level

@onready var hud = $CanvasLayer/HUD
@onready var player: Player

func _ready():
	player = get_node("Player")
	for c in get_children():
		if c.is_in_group("mobs") and c.has_method("initialize"):
			c.initialize()
		elif c is Player:
			player = c
	if player != null:
		print(player)
		hud.initialize(player)
	GlobalLevel.level_root = self
	initialize()
	
func initialize() -> void:
	pass
