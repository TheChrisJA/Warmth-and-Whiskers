extends NinePatchRect

@onready var grid = $SlotGrid
@onready var cursor = $SelectorCursor

func _ready():
	# Loop through all slots and connect their signal to this script
	for slot in grid.get_children():
		slot.slot_clicked.connect(_on_slot_clicked)
	
	# Optional: Hide cursor until something is clicked
	cursor.hide()

func _on_slot_clicked(index):
	update_cursor_position(index)
	cursor.show()

func update_cursor_position(index):
	var target_slot = grid.get_child(index)
	
	# The centering math from before
	var slot_center = target_slot.global_position + (target_slot.size / 2.0)
	cursor.global_position = slot_center - (cursor.size / 2.0)
	
	# This will hold references to all your slot nodes
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
