# InventorySlot.gd
extends TextureRect

signal slot_clicked(index)


func _gui_input(event):
	if event is InputEventMouseButton:
		# Check for left click and only when pressed down
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("slot_clicked", get_index())


func _on_gui_input(event: InputEvent) -> void:
	pass # Replace with function body.

func _ready():
	# Tell the global system this slot is available to hold items
	InventorySystem.register_slot(self)
	
	# Optional: Ensure the icon starts empty
	$ItemIcon.texture = null
