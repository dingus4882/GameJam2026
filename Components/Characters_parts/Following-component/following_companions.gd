class_name FollowingCompanions
extends Node

var followers: Array[Node2D] = []

@export var target: Node2D
@export var follow_distance: float = 100.0
@export var follow_speed: float = 4.5
@export var idle_follow_speed: float = 0.08
@export var reformation_speed: float = 3.8
@export var follower_scale: Vector2 = Vector2(0.5, 0.5)
@export var walk_side_offset: float = 50.0
@export var walk_vertical_offset: float = -20.0
@export var idle_wander_radius: float = 220.0
@export var player_avoidance_radius: float = 140.0
@export var idle_path_radius: float = 180.0
@export var idle_path_speed: float = 0.35
@export var min_follower_spacing: float = 50.0

@export var debug_add_followers: bool = false

var is_following_active = true
var ground_tilemap_cache: TileMapLayer = null

func _ready():
	if not is_instance_valid(target):
		target = get_parent()
	
	if debug_add_followers:
		call_deferred("_debug_spawn_followers")

func _debug_spawn_followers():
	var strong_enemy_scene = load("res://Main/Entities/Strong_enemy/Glorbo_strong.tscn")
	var fast_enemy_scene = load("res://Main/Entities/Fast_enemy/Glorbo_fast.tscn")
	var durable_enemy_scene = load("res://Main/Entities/Durable_enemy/Glorbo_durable.tscn")

	var enemies_to_spawn = [strong_enemy_scene, fast_enemy_scene, durable_enemy_scene]
	var spawn_offset = Vector2(150, 0)

	for enemy_scene in enemies_to_spawn:
		var enemy = enemy_scene.instantiate()
		# Add to the same parent as the player to be in the same space.
		target.get_parent().add_child(enemy)
		enemy.global_position = target.global_position + spawn_offset
		add_follower(enemy)
		spawn_offset += Vector2(150, 0)

func _disable_node_recursively(node: Node) -> void:
	if not is_instance_valid(node):
		return

	if node is AnimatedSprite2D or node is Sprite2D:
		for child in node.get_children():
			_disable_node_recursively(child)
		return

	node.set_process(false)
	node.set_physics_process(false)
	node.set_process_input(false)
	node.set_process_unhandled_input(false)
	node.set_process_shortcut_input(false)
	node.set_process_unhandled_key_input(false)

	for child in node.get_children():
		_disable_node_recursively(child)

func _get_animated_sprite(node: Node2D) -> AnimatedSprite2D:
	var sprite = node.get_node_or_null("Sprite")
	if sprite is AnimatedSprite2D:
		return sprite

	sprite = node.get_node_or_null("AnimatedSprite2D")
	if sprite is AnimatedSprite2D:
		return sprite

	return null

func add_follower(follower: Node2D):
	follower.scale = follower_scale

	# Keep the formation evenly spaced with a combined 75px diagonal offset.
	var diagonal_offset: float = 75.0
	follower.set_meta("follow_offset_idle", Vector2(diagonal_offset, diagonal_offset))
	follower.set_meta("follow_offset_move", Vector2(diagonal_offset + 20.0, diagonal_offset - 15.0))
	follower.set_meta("follow_offset", Vector2(diagonal_offset, diagonal_offset))
	var follower_type = follower.get_class()
	var idle_speed = 0.35 + (follower_type.hash() % 5) * 0.04
	follower.set_meta("idle_speed", idle_speed)
	follower.set_meta("orbit_phase", randf_range(0.0, TAU))
	follower.set_meta("orbit_speed", 0.45 + idle_speed * 0.2)
	follower.set_meta("path_direction", 1.0 if randf() < 0.5 else -1.0)
	follower.set_meta("path_bias", randf_range(-0.35, 0.35))
	follower.set_meta("path_frequency", 0.75 + randf_range(0.0, 0.25))

	# Disable collision to prevent followers from interacting with the world or player.
	if follower is CollisionObject2D:
		follower.collision_layer = 0
		follower.collision_mask = 0

	# Disable collision shapes so they cannot physically hit the player or world.
	for collision_shape in follower.find_children("*", "CollisionShape2D", true):
		if collision_shape is CollisionShape2D:
			collision_shape.set_deferred("disabled", true)

	# Disable attack components and their bullets to prevent followers from dealing damage.
	var attack_component = follower.get_node_or_null("AttackComponent")
	if attack_component:
		if "can_fire" in attack_component:
			attack_component.set("can_fire", false)
		for child in attack_component.get_children():
			if child is Area2D:
				child.set_deferred("monitoring", false)
				child.set_deferred("monitorable", false)
				for subchild in child.get_children():
					if subchild is CollisionShape2D:
						subchild.set_deferred("disabled", true)

	# Disable the follower's own AI/physics processing to stop them from falling or moving on their own.
	_disable_node_recursively(follower)

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

func _find_ground_tilemap() -> TileMapLayer:
	if is_instance_valid(ground_tilemap_cache):
		return ground_tilemap_cache

	var root = get_tree().current_scene
	if not is_instance_valid(root):
		root = get_tree().root

	var stack: Array[Node] = [root]
	while stack.size() > 0:
		var node = stack.pop_back()
		if node is TileMapLayer:
			ground_tilemap_cache = node
			return node
		for child in node.get_children():
			stack.append(child)

	return null

func _is_grounded_position(world_pos: Vector2) -> bool:
	var tilemap = _find_ground_tilemap()
	if not is_instance_valid(tilemap):
		return false

	var map_pos = tilemap.local_to_map(tilemap.to_local(world_pos))
	return tilemap.get_cell_source_id(map_pos) != -1

func _get_idle_path_target(follower: Node2D, player_position: Vector2, delta: float) -> Vector2:
	var orbit_phase = follower.get_meta("orbit_phase", randf_range(0.0, TAU))
	var orbit_speed = follower.get_meta("orbit_speed", 0.35)
	var path_direction = follower.get_meta("path_direction", 1.0)
	var path_bias = follower.get_meta("path_bias", 0.0)
	var path_angle = orbit_phase + path_direction * (0.8 + orbit_speed * 0.2) + path_bias
	var orbit_radius = idle_path_radius + (follower.get_instance_id() % 5) * 18.0
	var candidate = player_position + Vector2(cos(path_angle), sin(path_angle * (0.65 + abs(path_bias) * 0.2))) * orbit_radius
	candidate.y -= 35.0
	if _is_grounded_position(candidate):
		candidate.y -= 60.0
	follower.set_meta("orbit_phase", orbit_phase + idle_path_speed * delta * (0.8 + orbit_speed * 0.2))
	return candidate

func _physics_process(delta: float):
	if not is_following_active or not is_instance_valid(target):
		return

	var i = 0
	var previous_position: Vector2 = target.global_position
	var desired_positions: Array[Vector2] = []
	while i < followers.size():
		var follower = followers[i]
		if not is_instance_valid(follower):
			followers.remove_at(i)
			continue
		
		var player_is_moving = false
		var movement_direction_x: float = 0.0
		if target is CharacterBody2D:
			movement_direction_x = target.velocity.x
			player_is_moving = abs(movement_direction_x) > 10.0
		elif "current_state" in target and "States" in target:
			player_is_moving = target.get("current_state") == target.get("States").MOVE

		var target_pos: Vector2
		if player_is_moving:
			var side_sign = -sign(movement_direction_x)
			if side_sign == 0.0:
				side_sign = -1.0 if target.scale.x >= 0 else 1.0

			var anchor_position: Vector2
			if i == 0:
				anchor_position = target.global_position + Vector2(side_sign * walk_side_offset, walk_vertical_offset)
			else:
				var path_direction = follower.get_meta("path_direction", 1.0)
				var path_bias = follower.get_meta("path_bias", 0.0)
				var path_frequency = follower.get_meta("path_frequency", 1.0)
				var spread_x = 70.0 + (i % 4) * 24.0 + path_direction * 12.0
				var spread_y = -18.0 + (i % 3) * 20.0 + path_bias * 14.0
				var wave = sin((float(i) + 1.0) * (0.8 + path_frequency) + follower.get_meta("orbit_phase", 0.0))
				var offset = Vector2(side_sign * spread_x + path_direction * 8.0, spread_y + wave * (12.0 + abs(path_bias) * 8.0))
				anchor_position = target.global_position + offset

			target_pos = anchor_position
			previous_position = target_pos
		else:
			target_pos = _get_idle_path_target(follower, target.global_position, delta)

		if not player_is_moving and (target_pos - target.global_position).length() < player_avoidance_radius:
			target_pos = target.global_position + (target_pos - target.global_position).normalized() * player_avoidance_radius

		if player_is_moving:
			for other_index in range(i):
				var other_target = desired_positions[other_index]
				var separation = target_pos - other_target
				var separation_len = separation.length()
				if separation_len > 0.0 and separation_len < min_follower_spacing:
					var push = separation.normalized() * (min_follower_spacing - separation_len)
					target_pos += push

		desired_positions.append(target_pos)
		var direction = target_pos - follower.global_position
		var animated_sprite = _get_animated_sprite(follower)
		var is_repositioning = direction.length() > 5.0
		var should_face_left = direction.x < 0.0
		
		var move_speed = follow_speed if player_is_moving else idle_follow_speed
		if not player_is_moving and is_repositioning:
			var idle_speed = follower.get_meta("idle_speed", 0.35)
			follower.global_position = follower.global_position.lerp(target_pos, clampf(reformation_speed * delta * idle_speed, 0.0, 1.0))
		elif is_repositioning:
			follower.global_position = follower.global_position.lerp(target_pos, clampf(move_speed * delta, 0.0, 1.0))
		else:
			follower.global_position = target_pos
		
		if animated_sprite:
			animated_sprite.flip_h = should_face_left
			var anim_name = "walk" if (player_is_moving or is_repositioning) and animated_sprite.sprite_frames.has_animation("walk") else "idle"
			var idle_anim = "idle" if animated_sprite.sprite_frames.has_animation("idle") else "default"
			var next_anim = anim_name if (player_is_moving or is_repositioning) else idle_anim
			if animated_sprite.animation != next_anim:
				animated_sprite.play(next_anim)
		
		i += 1
