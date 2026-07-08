class_name HealthComponent
extends Node

@export var max_health: float = 100.0

@export var health_bar: ProgressBar
var current_health: float

var _following_companions: FollowingCompanions

signal died
signal health_changed(new_health: float, max_health: float)

func _ready() -> void:
	# This component is often on a character that might have followers.
	# We get the sibling node to check against it when taking damage.
	if get_parent().has_node("FollowingCompanions"):
		_following_companions = get_parent().get_node("FollowingCompanions")

	if health_bar != null:
		health_bar.max_value = self.max_health
		health_bar.value = self.max_health
	
	current_health = max_health

func take_damage(amount: int, damage_source: Node = null):
	if _following_companions and damage_source:
		# If the damage source is a follower, or owned by a follower (like a projectile), ignore it.
		var source = damage_source
		# This assumes projectiles/attacks have an 'owner' property pointing to who created them.
		if "owner" in source and source.owner is Node:
			source = source.owner
		
		if _following_companions.followers.has(source):
			return # Damage from a follower is ignored.

	current_health -= amount
	health_changed.emit(current_health, max_health)
	if health_bar != null:
		health_bar.value = current_health
	
	if current_health <= 0:
		died.emit()
		get_node("..").queue_free()


func heal_damage(amount: int):
	current_health = clampf(current_health + amount, 0, max_health)
	if health_bar != null:
		health_bar.value = current_health
	health_changed.emit(current_health, max_health)
