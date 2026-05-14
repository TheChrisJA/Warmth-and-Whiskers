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
