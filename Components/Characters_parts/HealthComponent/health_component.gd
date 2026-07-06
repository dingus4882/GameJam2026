class_name HealthComponent
extends Node

@export var max_health: float = 100.0

@export var health_bar: ProgressBar
var current_health: float



signal died
signal health_changed(new_health: float, max_health: float)

func _ready() -> void:
	if health_bar != null:
		health_bar.max_value = self.max_health
		health_bar.value = self.max_health
	
	current_health = max_health

func take_damage(amount: int):
	current_health -= amount
	health_changed.emit(current_health, max_health)
	if health_bar != null:
		health_bar.value = current_health
	
	if current_health <= 0:
		died.emit()
		get_node("..").queue_free()
	

func heal_damage(amount: int):
	current_health = clampf(current_health + amount, 0, max_health)
	health_bar.value = current_health
	health_changed.emit(current_health, max_health)
