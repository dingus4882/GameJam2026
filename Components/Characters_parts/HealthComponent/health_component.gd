class_name HealthComponent
extends Node

@export var max_health: float = 100.0

@export var health_bar: ProgressBar
var is_dead: bool = false
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
	if is_dead:
		return

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
		is_dead = true
		died.emit()

		# Check if this is an enemy killed by the player, to convert it into a companion.
		if get_parent().has_node("Base_Ai"): # A simple way to identify enemies.
			var killer = damage_source

			#if killer and "owner" in killer and killer.owner is Node:
			#	killer = killer.owner

			if killer and killer.get_node_or_null("FollowingCompanions") != null:
				var following_comp = killer.get_node_or_null("FollowingCompanions")
				print(following_comp)
				if following_comp:
					following_comp.add_follower(get_parent())
					return # Converted to follower, so we don't queue_free.

		# If not converted, or if it's the player, die normally.
		get_node("..").queue_free()


func heal_damage(amount: int):
	current_health = clampf(current_health + amount, 0, max_health)
	if health_bar != null:
		health_bar.value = current_health
	health_changed.emit(current_health, max_health)

func fully_heal():
	current_health = max_health
	if health_bar != null:
		health_bar.value = current_health
	health_changed.emit(current_health, max_health)
