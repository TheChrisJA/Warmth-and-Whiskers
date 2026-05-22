extends Node

signal heat_changed(new_heat: float)

@export var max_heat: float = 100.0
@export var min_heat: float = 0.0

# Initial baseline warmth
var current_heat: float = 50:
	set(value):
		current_heat = clamp(value, min_heat, max_heat)
		heat_changed.emit(current_heat)

# Environmental progression values
var ambient_drain_rate: float = 1.5 # Points lost per second initially
var freeze_acceleration: float = 0.05 # How much colder the world gets per second
var current_heating_bonus: float = 0.0 # Total heat influx from nearby objects

# The world gets progressively harsher over time
var environmental_freeze_rate: float = 1.5 

func _process(delta: float) -> void:
	# The baseline frost drain goes up constantly
	environmental_freeze_rate += freeze_acceleration * delta

func register_heat_source(amount: float) -> void:
	current_heating_bonus += amount

func unregister_heat_source(amount: float) -> void:
	current_heating_bonus -= amount
