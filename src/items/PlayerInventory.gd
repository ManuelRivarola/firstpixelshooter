extends Node

class ItemSlot:
	var item_name: String = "Empty"
	var amount: int = 0
	
	func is_slot_empty() -> bool:
		return self.item_name == "Empty"
	
	func is_slot_full(stack_size: int) -> bool:
		return self.amount == stack_size

var item_dictionary: Dictionary
var inventory: Array[ItemSlot]
var weapon_inventory: Array[PackedScene]
var unlocked_diaries: Array[String]

const WEAPON_SCENES = {
	"BoneDagger": "res://src/weapons/dagger/dagger.tscn",
	"Wand": "res://src/weapons/wand.tscn"
}

signal update_inventory
signal item_used(item_name: String, user: String)

func _ready():
	pass
	
func initialize_inventory(inventory_slots: int = 8) -> void:
	var path = "res://src/items/ItemDictionary.json"
	var json_as_string = FileAccess.get_file_as_string(path)
	item_dictionary = JSON.parse_string(json_as_string)
	for i in inventory_slots:
		inventory.append(ItemSlot.new())
		
	unlocked_diaries.append("Diary 0")

func item_stack_size(item_name: String) -> int:
	assert(item_dictionary.has(item_name))
	return item_dictionary[item_name]["stack_size"]

func add_item(item_name: String, amount: int) -> bool:
	assert(item_dictionary.has(item_name))
	var first_empty_slot = -1
	var added = false
	
	for i in range(inventory.size()):
		var item: ItemSlot = inventory[i]
		if item.item_name == item_name and item.amount + amount <= item_stack_size(item_name):
			inventory[i].amount  += amount
			added = true
			break
		if first_empty_slot == -1 and inventory[i].is_slot_empty():
			first_empty_slot = i
	
	if not added and first_empty_slot != -1:
		inventory[first_empty_slot].item_name = item_name
		inventory[first_empty_slot].amount = amount
		added = true
	
	if added:
		emit_signal("update_inventory")
	
	return added

func has_item(item_name: String) -> bool:
	## Chequea si existe actualmente el item en el inventario
	var exists = false
	
	for i in inventory:
		if i.item_name == item_name:
			exists = true
			break
	
	return exists

func use_item(item_name: String):
	assert(item_dictionary.has(item_name))
	assert(has_item(item_name))
	
	if item_dictionary[item_name]["consumable"]:
		consume_item(item_name, 1)
	print(typeof(item_name))
	print(typeof("item_used"))
	emit_signal("item_used", item_name, "Player")

func consume_item(item_name: String, amount: int) -> bool:
	assert(item_dictionary.has(item_name))
	var removed = false
	
	for i in inventory:
		if i.item_name == item_name:
			i.amount -= amount
			removed = true
			if i.amount <= 0:
				i.item_name = "Empty"
			break
		
	if removed:
		emit_signal("update_inventory")
	
	return removed
