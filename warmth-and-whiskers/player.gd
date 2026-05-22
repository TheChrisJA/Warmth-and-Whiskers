extends CharacterBody2D
class_name Player

const SPEED = 50
const INTERACTION_DISTANCE = 5

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var target_item: Area2D = null
# NEW: Track where the player wants to drop the item
var pending_placement_position: Vector2 = Vector2.ZERO
var is_moving_to_place: bool = false

signal heat_changed(new_heat: float)

@export var max_heat: float = 100.0
@export var min_heat: float = 0.0

var current_heat: float = 100:
	set(value):
		current_heat = clamp(value, min_heat, max_heat)
		heat_changed.emit(current_heat)

var local_heating_bonus: float = 0.0


func _ready():
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	add_to_group("player")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		# FIX: Ignore the click completely if the mouse is hovering over the inventory UI
		var mouse_pos = get_viewport().get_mouse_position()
		if InventorySystem.get_global_rect().has_point(mouse_pos):
			return # Stop execution so clicking slots never triggers player behavior!

		# If holding an item, walk to the click position instead of instant drop
		if InventorySystem.item_to_place != null:
			target_item = null
			is_moving_to_place = true
			pending_placement_position = get_global_mouse_position()
			set_movement_target(pending_placement_position)
			return 
			
		# Default movement logic
		target_item = null
		is_moving_to_place = false
		set_movement_target(get_global_mouse_position())

func set_movement_target(target_point: Vector2):
	nav_agent.target_position = target_point

func _physics_process(delta: float) -> void:
	# ─── HEAT & TEMPERATURE LOOP ───
	# Read the world's current base frost level from the global script
	var environmental_drain = GlobalHeat.environmental_freeze_rate
	
	# Combine regional warmth vs global freeze
	var net_change = local_heating_bonus - environmental_drain
	
	# Fix: 'self.' ensures it runs through the custom setter and triggers the UI signal
	self.current_heat += net_change * delta


	# ─── NAVIGATION & MOVEMENT LOOP ───
	# Check proximity for picking up an item
	if is_instance_valid(target_item):
		var distance_to_item = global_position.distance_to(target_item.global_position)
		if distance_to_item <= INTERACTION_DISTANCE:
			target_item.interact(self)
			target_item = null
			velocity = Vector2.ZERO
			return

	# NEW FEATURE: Check proximity for placing an item
	if is_moving_to_place:
		var distance_to_placement = global_position.distance_to(pending_placement_position)
		if distance_to_placement <= INTERACTION_DISTANCE:
			# Close enough! Deploy the item at the destination coordinates
			InventorySystem.deploy_item(pending_placement_position, get_parent())
			is_moving_to_place = false
			velocity = Vector2.ZERO
			return

	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var new_velocity: Vector2 = current_agent_position.direction_to(next_path_position) * SPEED

	velocity = new_velocity
	move_and_slide()
