extends Area2D

@export var heat_output: float = 5

var player_in_range: CharacterBody2D = null
var max_radius: float = 0.0
var circle_center: Vector2  # will hold the actual center of the circle

func _ready() -> void:
	for child in get_children():
		if child is CollisionShape2D and child.shape is CircleShape2D:
			max_radius = child.shape.radius
			circle_center = child.global_position   # <-- real center
			break

	if max_radius == 0.0:
		max_radius = 150.0
		circle_center = global_position   # fallback

func _process(delta: float) -> void:
	if is_instance_valid(player_in_range):
		var distance = circle_center.distance_to(player_in_range.global_position)
		distance = clamp(distance, 0.0, max_radius)

		var dropoff_factor = 1.0 - (distance / max_radius)
		player_in_range.local_heating_bonus = heat_output * dropoff_factor

		print("Dist: %.1f/%d | Factor: %.2f | Bonus: %.1f" % [distance, max_radius, dropoff_factor, player_in_range.local_heating_bonus])

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = body
		print("Player entered warmth zone. Beginning dynamic temperature scaling.")

func _on_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		# Reset their heat bonus back to 0 when they step completely outside the circle
		player_in_range.local_heating_bonus = 0.0
		player_in_range = null
		print("Player left warmth zone.")
