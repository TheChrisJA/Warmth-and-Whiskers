extends NinePatchRect

# Add this signal at the top (outside any function)
signal item_placed_successfully

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
	
	# 🟢 Emit the signal so the cursor script can react
	item_placed_successfully.emit()

func cancel_placement() -> void:
	item_to_place = null
	active_slot = null
