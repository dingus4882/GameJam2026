class_name FollowingCompanions
extends Node

var followers: Array[Node2D] = []

@export var target: Node2D
@export var follow_distance: float = 100.0
@export var follow_speed: float = 5.0
@export var follower_scale: Vector2 = Vector2(0.5, 0.5)

@export var debug_add_followers: bool = false

var is_following_active = true

func _ready():
	if not is_instance_valid(target):
		target = get_parent()
	
	if debug_add_followers:
		call_deferred("_debug_spawn_followers")

func _debug_spawn_followers():
	var strong_enemy_scene = preload("res://Main/Entities/Strong_enemy/strong_enemy.tscn")
	var fast_enemy_scene = preload("res://Main/Entities/Fast_enemy/fast_enemy.tscn")
	var durable_enemy_scene = preload("res://Main/Entities/Durable_enemy/durable_enemy.tscn")

	var enemies_to_spawn = [strong_enemy_scene, fast_enemy_scene, durable_enemy_scene]
	var spawn_offset = Vector2(150, 0)

	for enemy_scene in enemies_to_spawn:
		var enemy = enemy_scene.instantiate()
		# Add to the same parent as the player to be in the same space.
		target.get_parent().add_child(enemy)
		enemy.global_position = target.global_position + spawn_offset
		add_follower(enemy)
		# The enemy's _process is disabled by default when added as a follower.
		enemy.set_process(false) # Disable enemy AI
		spawn_offset += Vector2(150, 0)

func add_follower(follower: Node2D):
	follower.scale = follower_scale
	followers.append(follower)
	# The caller is responsible for disabling the enemy's default behavior.
	# e.g. enemy.set_process(false)

func sacrifice_follower_of_type(type_name: String) -> bool:
	for i in range(followers.size() - 1, -1, -1): # Iterate in reverse to find the last added
		var follower = followers[i]
		if is_instance_valid(follower) and follower.get_class() == type_name:
			remove_follower(follower)
			return true # Successfully sacrificed a follower
	return false # No follower of the specified type found



func remove_follower(follower: Node2D):
	var index = followers.find(follower)
	if index != -1:
		followers.remove_at(index)
		follower.queue_free() # Or whatever should happen to it.

func _physics_process(delta: float):
	if not is_following_active or not is_instance_valid(target):
		return

	var target_pos = target.global_position

	var i = 0
	while i < followers.size():
		var follower = followers[i]
		if not is_instance_valid(follower):
			followers.remove_at(i)
			continue

		var current_target_pos = target_pos if i == 0 else followers[i-1].global_position
		var direction = current_target_pos - follower.global_position
		if direction.length() > follow_distance:
			var movement_vector = direction.normalized() * follow_speed * delta
			follower.global_position += movement_vector

			# Update animation facing and play walk animation
			var animated_sprite = follower.get_node_or_null("AnimatedSprite2D")
			if animated_sprite:
				if movement_vector.x > 0:
					animated_sprite.flip_h = false
				elif movement_vector.x < 0:
					animated_sprite.flip_h = true
				animated_sprite.play("default") # Assuming "default" is the walking animation
		else:
			# Follower is close enough, make it idle
			var animated_sprite = follower.get_node_or_null("AnimatedSprite2D")
			if animated_sprite:
				animated_sprite.stop()
				animated_sprite.frame = 0 # Set to first frame of current animation (often idle)
		
		i += 1
