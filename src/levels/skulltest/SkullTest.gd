extends Level


func _on_button_pressed():
	var new_allegiance = "Enemy" if $Skull.allegiance == "Ally" else "Ally"
	$Skull.change_allegiance(new_allegiance)
