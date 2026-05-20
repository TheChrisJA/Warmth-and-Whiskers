extends TextureRect

signal slot_clicked(index)

func _ready():
	InventorySystem.register_slot(self)
	$ItemIcon.texture = null

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Tell the inventory system we want to place or deselect the item
			InventorySystem.try_prepare_placement(self)
			
			# Stop the click from passing through the UI onto the map ground
			get_viewport().set_input_as_handled()
			
			emit_signal("slot_clicked", get_index())

# ----- Drag & Drop -----
func _get_drag_data(at_position):
	# Only start drag if the slot actually contains an item
	var icon = $ItemIcon
	if icon.texture == null:
		return null
	
	# Cancel any active placement (clear selection cursor)
	InventorySystem.cancel_placement()
	
	# Create a preview that follows the mouse
	var preview = TextureRect.new()
	preview.texture = icon.texture
	preview.size = icon.size
	set_drag_preview(preview)
	
	# Return data about the dragged item
	var data = {
		"type": "inventory_item",
		"source_slot": get_index(),
		"item_texture": icon.texture,
		"item_name": get_meta("stored_item_name", "")
	}
	return data

func _can_drop_data(at_position, data):
	# Only accept our own drag data and drop onto a different slot
	if data is Dictionary and data.get("type") == "inventory_item":
		var source_idx = data.get("source_slot", -1)
		var target_idx = get_index()
		return source_idx != target_idx
	return false

func _drop_data(at_position, data):
	var source_idx = data.get("source_slot")
	var target_idx = get_index()
	# Tell the inventory system to move the item
	InventorySystem.move_item(source_idx, target_idx)
