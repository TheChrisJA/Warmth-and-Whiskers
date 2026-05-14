extends CharacterBody2D

const SPEED = 50
const WANDER_RANGE = 3000.0 # How far it can wander from its current spot

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var player: CharacterBody2D = $/root/MainGame/Systems/SpawnManager/Player # Drag your player into this slot in the Inspector

func _ready():
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0

func _physics_process(_delta: float) -> void:
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return

	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	velocity = global_position.direction_to(next_path_position) * SPEED
	move_and_slide()

# This function runs every time the Timer finishes
func _on_timer_timeout() -> void:
	var decision = randf() # Generates a number between 0.0 and 1.0

	if decision < 0.3 and player: 
		# 30% chance to move toward the player
		nav_agent.target_position = player.global_position
	else:
		# 70% chance to wander to a random nearby spot
		var random_offset = Vector2(
			randf_range(-WANDER_RANGE, WANDER_RANGE),
			randf_range(-WANDER_RANGE, WANDER_RANGE)
		)
		nav_agent.target_position = global_position + random_offset
