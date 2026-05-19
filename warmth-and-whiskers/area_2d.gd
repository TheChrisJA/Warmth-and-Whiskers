extends Area2D

# Assign the icon texture in the inspector that should appear in the UI
@export var inventory_icon: Texture2D 

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# Check if the player left-clicks the item
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		# Try to add it to the UI
		var was_picked_up = InventorySystem.add_item(inventory_icon)
		
		if was_picked_up:
			# Remove the item from the 2D world
			queue_free()
