extends Resource

class_name InventoryData

@export var slots: Array[ItemData] = []

func add_item(item: ItemData):
	for i in range(slots.size()):
		if slots[i] == null:
			slots[i] = item
			return true
	return false
