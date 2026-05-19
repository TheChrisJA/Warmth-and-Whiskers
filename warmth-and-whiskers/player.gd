extends CharacterBody2D

const SPEED = 50
# The distance (in pixels) the player needs to be from the item to pick it up
const INTERACTION_DISTANCE = 5 

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

# Keep track of the item the player is currently walking towards
var target_item: Area2D = null

func _ready():
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# If the player clicks empty ground, clear the current item target
		target_item = null
		set_movement_target(get_global_mouse_position())

func set_movement_target(target_point: Vector2):
	nav_agent.target_position = target_point

func _physics_process(_delta: float) -> void:
	# If we have an active target item, check if we are close enough to interact
	if is_instance_valid(target_item):
		var distance_to_item = global_position.distance_to(target_item.global_position)
		if distance_to_item <= INTERACTION_DISTANCE:
			target_item.interact(self) # Trigger the pickup on the item
			target_item = null # Clear target so we don't pick it up twice
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
