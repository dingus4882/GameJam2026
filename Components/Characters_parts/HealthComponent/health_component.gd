class_name HealthComponent
extends Node

@export var max_health: float = 100.0

var current_health: float

signal died
signal health_changed(new_health: float, max_health: float)

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int):
	current_health -= amount

	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		died.emit()
		get_node("..").queue_free()
	

func heal_damage(amount: int):
	current_health = clampf(current_health + amount, 0, max_health)
	health_changed.emit(current_health, max_health)
