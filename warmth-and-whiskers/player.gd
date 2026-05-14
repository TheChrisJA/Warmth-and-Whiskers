extends CharacterBody2D

const SPEED = 50

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _ready():
	# These help prevent the character from getting stuck on corners
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0

# Change _input to _unhandled_input
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		set_movement_target(get_global_mouse_position())

func set_movement_target(target_point: Vector2):
	nav_agent.target_position = target_point

func _physics_process(_delta: float) -> void:
	# Do nothing if we reached the end or the path is empty
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return

	# Find the next point in the path (calculated by the NavMesh)
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = nav_agent.get_next_path_position()

	# Calculate velocity to that specific sub-point
	var new_velocity: Vector2 = current_agent_position.direction_to(next_path_position) * SPEED

	# Simple move_and_slide logic
	velocity = new_velocity
	move_and_slide()
