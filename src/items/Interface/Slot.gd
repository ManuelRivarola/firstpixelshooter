extends MenuButton

class_name Slot

var item_name: String

func _ready():
	self.pressed.connect(_on_button_pressed)
	get_popup().id_pressed.connect(_on_id_pressed)
	custom_minimum_size = Vector2(40,40)
	icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	expand_icon = false
	item_name = "Empty"
	flat = false
	text = ""

func set_stack_size(_size: int):
	text = str(_size) if _size > 0 else ""

func get_stack_size() -> int:
	return int(text)

func is_full() -> bool:
	return int(text) == ItemIndex.get_item_property(item_name, "stack_size")

func is_empty() -> bool:
	return item_name == "Empty"

func set_item(_item_name: String, amount: int) -> void:
	get_popup().clear()
	get_popup().add_item("Use")
	if item_name != _item_name:
		item_name = _item_name
		icon = ItemIndex.get_item_property(_item_name, "icon")
		tooltip_text = item_name
	set_stack_size(amount)

func remove_item() -> void:
	get_popup().clear()
	item_name = "Empty"
	tooltip_text = ""
	icon = null
	set_stack_size(0)

func _on_button_pressed() -> void:
	print("Pressed! ", item_name)

func _on_about_to_popup() -> void:
	pass
	#get_popup().id_pressed.connect(_on_id_pressed)

func _on_id_pressed(id: int) -> void:
	if id == 0:
		PlayerInventory.use_item(item_name)

