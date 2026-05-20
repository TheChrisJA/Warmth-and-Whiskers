# InventorySlot.gd
extends TextureRect

signal slot_clicked(index)

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Tell the inventory system we want to place or deselect the item
			InventorySystem.try_prepare_placement(self)
			
			# STOP the click from passing through the UI onto the map ground
			get_viewport().set_input_as_handled()
			
			emit_signal("slot_clicked", get_index())

func _on_gui_input(event: InputEvent) -> void:
	pass 

func _ready():
	InventorySystem.register_slot(self)
	$ItemIcon.texture = null
