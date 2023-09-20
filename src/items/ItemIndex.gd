extends Node

var index := {}

func _ready():
	initialize_inventory()

func initialize_inventory() -> void:
	const dict_path = "res://src/items/ItemDictionary.json"
	var json_as_string = FileAccess.get_file_as_string(dict_path)
	var item_dictionary: Dictionary = JSON.parse_string(json_as_string)
	
	for item_name in item_dictionary:
		var item = item_dictionary[item_name].duplicate()
		if item.has("icon_path"):
			var icon = load(item["icon_path"])
			item["icon"] = icon
			item.erase("icon_path")
		if item.has("mesh_path"):
			var mesh = load(item["mesh_path"])
			item["mesh"] = mesh
			item.erase("mesh_path")
		index[item_name] = item

func get_item_property(item_name: String, property: String):
	if !index.has(item_name) or !index[item_name].has(property):
		return null
	
	return index[item_name][property]

func item_exists(item_name: String):
	return index.has(item_name)

func get_item(item_name: String):
	if !index.has(item_name):
		return null
		
	return index[item_name]
