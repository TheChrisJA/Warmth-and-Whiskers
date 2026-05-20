extends NinePatchRect

signal item_placed_successfully
signal item_moved(from_slot, to_slot)   # new signal

var slots: Array = []
var item_to_place: PackedScene = null
var active_slot: TextureRect = null

func register_slot(slot_node):
	if not slots.has(slot_node):
		slots.append(slot_node)
		slot_node.set_meta("stored_item_name", "")

func add_item(item_texture: Texture2D, item_name: String) -> bool:
	for slot in slots:
		var icon_rect = slot.get_node("ItemIcon") 
		if icon_rect.texture == null:
			icon_rect.texture = item_texture
			slot.set_meta("stored_item_name", item_name)
			return true 
	print("Inventory is full!")
	return false 

# new function: move item from source slot to target slot (swap if target is occupied)
func move_item(source_idx: int, target_idx: int) -> void:
	if source_idx == target_idx:
		return
	var source = slots[source_idx]
	var target = slots[target_idx]
	var source_icon = source.get_node("ItemIcon")
	var target_icon = target.get_node("ItemIcon")
	
	# Swap textures
	var temp_texture = source_icon.texture
	source_icon.texture = target_icon.texture
	target_icon.texture = temp_texture
	
	# Swap metadata
	var temp_name = source.get_meta("stored_item_name", "")
	source.set_meta("stored_item_name", target.get_meta("stored_item_name", ""))
	target.set_meta("stored_item_name", temp_name)
	
	emit_signal("item_moved", source_idx, target_idx)

func try_prepare_placement(slot_node: TextureRect) -> void:
	print("try_prepare_placement called with slot: ", slot_node.name)
	var icon_rect = slot_node.get_node("ItemIcon")
	if icon_rect.texture == null:
		return

	if active_slot == slot_node:
		cancel_placement()
		print("Deselected item. Placement canceled.")
		return
		
	var item_name = slot_node.get_meta("stored_item_name", "")
	print("Preparing to place: ", item_name)
	
	var save_path = "user://saved_area.tscn"
	if ResourceLoader.exists(save_path):
		item_to_place = ResourceLoader.load(save_path) as PackedScene
		active_slot = slot_node
		print("Placement mode active. Click on the ground to place item.")
	else:
		print("Error: Save file missing!")

func deploy_item(spawn_position: Vector2, world_node: Node) -> void:
	if item_to_place == null or active_slot == null:
		return
		
	var new_item = item_to_place.instantiate() as Area2D
	new_item.global_position = spawn_position
	world_node.add_child(new_item)
	
	active_slot.get_node("ItemIcon").texture = null
	active_slot.set_meta("stored_item_name", "")
	
	item_to_place = null
	active_slot = null
	print("Item successfully placed back into the world!")
	item_placed_successfully.emit()

func cancel_placement() -> void:
	item_to_place = null
	active_slot = null
