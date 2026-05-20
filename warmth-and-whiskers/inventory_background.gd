extends NinePatchRect

@onready var grid = $SlotGrid
@onready var cursor = %SelectorCursor

var current_selected_index := -1

# Reference to the placement script (adjust the path to match your scene tree)  # Example path

func _ready():
	# Connect slots
	for slot in grid.get_children():
		slot.slot_clicked.connect(_on_slot_clicked)
	
	# Connect to the placement script's signal if it exists
	if InventorySystem:
		InventorySystem.item_placed_successfully.connect(_on_item_placed)
	
	cursor.hide()

func _on_slot_clicked(index):
	if index == current_selected_index:
		cursor.hide()
		current_selected_index = -1
	else:
		update_cursor_position(index)
		cursor.show()
		current_selected_index = index

func update_cursor_position(index):
	var target_slot = grid.get_child(index)
	var slot_center = target_slot.global_position + (target_slot.size / 2.0)
	cursor.global_position = slot_center - (cursor.size / 2.0)

# Called when an item is successfully placed into the world
func _on_item_placed():
	cursor.hide()
	current_selected_index = -1

# ----- Inventory system (unchanged) -----
var slots: Array = []

func register_slot(slot_node):
	if not slots.has(slot_node):
		slots.append(slot_node)

func add_item(item_texture: Texture2D) -> bool:
	for slot in slots:
		var icon_rect = slot.get_node("ItemIcon")
		if icon_rect.texture == null:
			icon_rect.texture = item_texture
			return true
	print("Inventory is full!")
	return false
