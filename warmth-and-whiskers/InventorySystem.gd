extends NinePatchRect

var slots: Array = []

# Slots will call this when they enter the scene tree
func register_slot(slot_node):
	if not slots.has(slot_node):
		slots.append(slot_node)

# World items will call this when clicked
func add_item(item_texture: Texture2D) -> bool:
	for slot in slots:
		# Assuming ItemIcon is a TextureRect child of the slot
		var icon_rect = slot.get_node("ItemIcon") 
		
		# If the slot is empty (no texture), put the item here
		if icon_rect.texture == null:
			icon_rect.texture = item_texture
			return true # Successfully picked up
			
	print("Inventory is full!")
	return false # Failed to pick up
