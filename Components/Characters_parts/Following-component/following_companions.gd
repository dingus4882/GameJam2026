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
	var strong_enemy_scene = preload("res://Main/Entities/Strong_enemy/Glorbo_strong.tscn")
	var fast_enemy_scene = preload("res://Main/Entities/Fast_enemy/Glorbo_fast.tscn")
	var durable_enemy_scene = preload("res://Main/Entities/Durable_enemy/Glorbo_durable.tscn")

	var enemies_to_spawn = [strong_enemy_scene, fast_enemy_scene, durable_enemy_scene]
	var spawn_offset = Vector2(150, 0)

	for enemy_scene in enemies_to_spawn:
		var enemy = enemy_scene.instantiate()
		# Add to the same parent as the player to be in the same space.
		target.get_parent().add_child(enemy)
		enemy.global_position = target.global_position + spawn_offset
		add_follower(enemy)
		spawn_offset += Vector2(150, 0)

func add_follower(follower: Node2D):
	follower.scale = follower_scale

	# Assign a random offset for the follower to create a scattered formation.
	var horizontal_offset = randf_range(75.0, 150.0) # The horizontal distance from the player.
	var vertical_offset = randf_range(0, 100.0) # The vertical distance (positive is down).
	follower.set_meta("follow_offset", Vector2(horizontal_offset, vertical_offset))

	# Disable collision to prevent followers from interacting with the world or player.
	if follower is CollisionObject2D:
		follower.collision_layer = 0
		follower.collision_mask = 0

	# Disable attack components to prevent followers from dealing damage.
	var attack_component = follower.get_node_or_null("AttackComponent")
	if attack_component and "bullets" in attack_component:
		var bullets = attack_component.get("bullets")
		for bullet_path in bullets:
			var bullet_node = attack_component.get_node_or_null(bullet_path)
			if bullet_node and bullet_node is Area2D:
				bullet_node.set_deferred("monitoring", false)
				bullet_node.set_deferred("monitorable", false)
				
	# Disable the follower's own AI/physics processing to stop them from falling or moving on their own.
	follower.set_process(false)
	follower.set_physics_process(false)

	followers.append(follower)

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

	var i = 0
	while i < followers.size():
		var follower = followers[i]
		if not is_instance_valid(follower):
			followers.remove_at(i)
			continue
		
		var follow_offset: Vector2 = follower.get_meta("follow_offset", Vector2.ZERO)
		
		# Adjust horizontal offset based on player's direction
		if "is_sprite_towards_the_right" in target and not target.is_sprite_towards_the_right: # Player is facing left
			follow_offset.x = abs(follow_offset.x)
		else: # Player is facing right
			follow_offset.x = -abs(follow_offset.x)
			
		var target_pos = target.global_position + follow_offset
		var direction = target_pos - follower.global_position
		
		var animated_sprite = follower.get_node_or_null("AnimatedSprite2D")
		
		if direction.length() > 5.0: # Threshold to start moving and prevent jittering
			follower.global_position = follower.global_position.lerp(target_pos, follow_speed * delta)
			if animated_sprite:
				if direction.x > 0.1:
					animated_sprite.flip_h = false
				elif direction.x < -0.1:
					animated_sprite.flip_h = true
				animated_sprite.play("default")
		else:
			if animated_sprite:
				animated_sprite.stop()
				animated_sprite.frame = 0 # Set to first frame of current animation (often idle)
		
		i += 1
