extends Label

func _ready() -> void:
	# Safely wait for the main scene to finish assembling
	await get_tree().process_frame
	
	# Locate the player node inside the group we assigned earlier
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var target_player = players[0] as Player
		
		# Hook into this specific player's signal
		target_player.heat_changed.connect(_on_player_heat_changed)
		_update_display(target_player.current_heat)

func _on_player_heat_changed(new_heat: float) -> void:
	_update_display(new_heat)

func _update_display(value: float) -> void:
	text = "%d%%" % [round(value)]
	
	if value < 25.0:
		add_theme_color_override("font_color", Color.CRIMSON)
	else:
		add_theme_color_override("font_color", Color.WHITE)
