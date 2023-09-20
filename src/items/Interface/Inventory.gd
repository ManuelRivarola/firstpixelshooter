extends Control

class_name Inventory

@onready var grid_container: GridContainer = $GridContainer
@export var inventory_size: int = 8

func _ready():
	initialize()

func initialize():
	PlayerInventory.initialize_inventory(inventory_size)
	PlayerInventory.update_inventory.connect(_on_update_inventory)
	for i in inventory_size:
		var slot = Slot.new()
		grid_container.add_child(slot)


func _on_update_inventory():
	var slots = grid_container.get_children()
	
	for i in inventory_size:
		if PlayerInventory.inventory[i].is_slot_empty():
			slots[i].remove_item()
		else:
			var item_name = PlayerInventory.inventory[i].item_name
			var amount = PlayerInventory.inventory[i].amount
			slots[i].set_item(item_name, amount)

func _on_add_test_item_pressed():
	var added = PlayerInventory.add_item("HealthPotion", 1)
	if added:
		print("Added!")
	else:
		print("Not added!")


func _on_remove_test_item_pressed():
	var removed = PlayerInventory.consume_item("HealthPotion", 1)
	if removed:
		print("Removed!")
	else:
		print("Not removed!")
