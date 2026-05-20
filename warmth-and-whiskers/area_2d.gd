extends Area2D

@export var inventory_icon: Texture2D 
@export var item_name: String = "Unnamed Item" # Added item name property

const SAVE_PATH = "user://saved_area.tscn"

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var player = get_node("/root/MainGame/Systems/SpawnManager/Player")
		
		if player:
			player.target_item = self
			player.set_movement_target(global_position)
			get_viewport().set_input_as_handled()

func interact(player_node: CharacterBody2D) -> void:
	# Pass both the texture AND the name to the InventorySystem
	var was_picked_up = InventorySystem.add_item(inventory_icon, item_name)
	
	if was_picked_up:
		save_area(self)
		queue_free()

func save_area(area_to_save: Area2D) -> void:
	area_to_save.position = Vector2.ZERO
	
	for child in area_to_save.get_children():
		child.owner = area_to_save
		
	var packed_scene = PackedScene.new()
	var result = packed_scene.pack(area_to_save)
	
	if result == OK:
		var save_result = ResourceSaver.save(packed_scene, SAVE_PATH)
		if save_result == OK:
			print("Area2D and its children saved successfully!")
		else:
			print("Failed to save file to disk. Error code: ", save_result)
	else:
		print("Failed to pack the Area2D node. Error code: ", result)
