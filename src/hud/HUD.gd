extends Control

@onready var health_label = $HealthLabel
@onready var inventory = $Inventory
@onready var interactable_label = $InteractableLabel
@onready var diary_label = $DiaryText

var diary_dictionary: Dictionary

func _ready():
	var json_as_string = FileAccess.get_file_as_string("res://src/items/DiaryDictionary.json")
	diary_dictionary = JSON.parse_string(json_as_string)

func initialize(player: Player):
	$ItemList.visible = false
	inventory.visible = false
	diary_label.visible = false
	print(player)
	player.health_changed.connect(_on_health_changed)
	player.inventory_activated.connect(_on_inventory_activation)
	player.damage_received.connect(_on_player_damage_received)
	player.looking_at_item.connect(_on_looking_at_item)
	set_health(player.current_hp)

func set_health(health):
	health_label.text = str(health)

func show_diary_text(text: String):
	diary_label.text = text
	$DiaryText/ColorRect.visible = true
	$ScrollSpeedTimer.start()

func _on_health_changed(new_health):
	set_health(new_health)

func _on_inventory_activation():
	$ItemList.visible = $ItemList.visible == false
	inventory.visible = inventory.visible == false
	diary_label.visible = diary_label.visible == false
	if diary_label.text != "":
		diary_label.text = ""
		diary_label.visible_characters = 0

func _on_looking_at_item(item_name: String):
	interactable_label.text = item_name

func _on_player_damage_received(damage: int, _msg = {}):
	var tween = get_tree().create_tween()
	tween.set_loops(1)
	$HitColor.color += Color(0, 0, 0, 0.8)
	tween.tween_property($HitColor, "color", Color(255, 0, 0, 0), 0.35)

func _on_scroll_speed_timer_timeout():
	diary_label.visible_characters += 1
	$DiaryText/ColorRect.set_size(diary_label.size)
	if diary_label.visible_ratio < 1.0:
		$ScrollSpeedTimer.start()


func _on_item_list_item_activated(index):
	var diary = $ItemList.get_item_text(index)
	if diary == "Diary 1":
		print("Showing ", diary)
		$TextureRect.visible = false if $TextureRect.visible else true
	else:
		show_diary_text(diary_dictionary[diary]["content"])
