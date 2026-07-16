class_name FollowingCompanions
extends Node

# Companion Scene Library
const BRAINLESS = "res://Main/Entities/BrainlessBlackAndWhite_enemy/glorbo_brainless.tscn"
const BRAINLESS_WHITE = "res://Main/Entities/BrainlessBlackAndWhite_enemy/glorbo_brainlessWhite.tscn"
const DURABLE = "res://Main/Entities/Durable_enemy/Glorbo_durable.tscn"
const FAST = "res://Main/Entities/Fast_enemy/Glorbo_fast.tscn"
const FIRE = "res://Main/Entities/Fire_enemy/glorbo_fire.tscn"
const FOUR_ARMED = "res://Main/Entities/FourArmed_enemy/glorbo_fourarmed.tscn"
const MAGMA = "res://Main/Entities/MagmaMiniBoss_enemy/glorbo_magma.tscn"
const STRONG = "res://Main/Entities/Strong_enemy/Glorbo_strong.tscn"


var followers: Array[Node2D] = []

@export var target: Node2D
@export var follow_distance: float = 75.0
@export var follow_speed: float = 4.5
@export var idle_follow_speed: float = 0.08
@export var reformation_speed: float = 3.8
@export var follower_scale: Vector2 = Vector2(0.5, 0.5)
@export var walk_side_offset: float = 50.0
@export var walk_vertical_offset: float = -20.0
@export var idle_wander_radius: float = 100.0
@export var player_avoidance_radius: float = 50.0
@export var idle_path_radius: float = 100.0 
@export var idle_path_speed: float = 0.35
@export var min_follower_spacing: float = 50.0

@export var debug_add_followers: bool = false

var is_following_active = true
var ground_tilemap_cache: TileMapLayer = null

var _sacrificing_follower: Node2D = null
@onready var _sacrifice_particles: CPUParticles2D = $"../CPUParticles2D"
@onready var _mouth_pos: Node2D = $"../moutn_pos"

func _ready():
	if not is_instance_valid(target):
		target = get_parent()
	
	_sacrifice_particles.process_mode = Node.PROCESS_MODE_ALWAYS

	if not _sacrifice_particles.texture:
		var gradient = Gradient.new()
		# A gradient from opaque white in the center to transparent white at the edge.
		gradient.offsets = PackedFloat32Array([0.0, 1.0])
		gradient.colors = PackedColorArray([Color.WHITE, Color(1, 1, 1, 0)])

		var gradient_tex = GradientTexture2D.new()
		gradient_tex.gradient = gradient
		gradient_tex.width = 16
		gradient_tex.height = 16
		gradient_tex.fill = GradientTexture2D.FILL_RADIAL
		_sacrifice_particles.texture = gradient_tex

	if debug_add_followers:
		call_deferred("_debug_spawn_followers")

func _debug_spawn_followers():
	# Spawns a few companions for debugging.
	var enemies_to_spawn = [STRONG, FAST, DURABLE]
	var spawn_offset = Vector2(150, 0)

	for enemy_path in enemies_to_spawn:
		var enemy_scene = load(enemy_path)
		var enemy = enemy_scene.instantiate()
		target.get_parent().add_child(enemy)
		enemy.global_position = target.global_position + spawn_offset
		add_follower(enemy)
		spawn_offset += Vector2(150, 0)

func _get_animated_sprite(node: Node2D) -> AnimatedSprite2D:
	var sprite = node.get_node_or_null("Sprite")
	if sprite is AnimatedSprite2D:
		return sprite

	sprite = node.get_node_or_null("AnimatedSprite2D")
	if sprite is AnimatedSprite2D:
		return sprite

	return null

func add_follower(follower: Node2D):
	_disable_enemy_components(follower)
	_initialize_follower_metadata(follower)
	followers.append(follower)

func _disable_enemy_components(follower: Node2D):
	# Disables AI and physics processing.
	var ai_node = follower.get_node_or_null("Base_Ai")
	if ai_node:
		ai_node.set_physics_process(false)
	follower.set_physics_process(false)

	# Disable all collision shapes.
	if follower is CollisionObject2D:
		follower.collision_layer = 0
		follower.collision_mask = 0
	for collision_shape in follower.find_children("*", "CollisionShape2D", true):
		collision_shape.set_deferred("disabled", true)

	# Disable attack components.
	var attack_component = follower.get_node_or_null("AttackComponent")
	if attack_component:
		attack_component.set_process(false)
		if "can_fire" in attack_component:
			attack_component.set("can_fire", false)

func _initialize_follower_metadata(follower: Node2D):
	follower.scale = follower_scale

	# Use the scene path as a type identifier.
	var follower_type = follower.scene_file_path
	follower.set_meta("companion_type", follower_type)
	
	# These meta properties add variation and personality to each follower's movement.
	var idle_speed = 0.35 + (follower_type.hash() % 5) * 0.04
	follower.set_meta("idle_speed", idle_speed)
	follower.set_meta("orbit_phase", randf_range(0.0, TAU))
	follower.set_meta("orbit_speed", 0.45 + idle_speed * 0.2)
	follower.set_meta("path_direction", 1.0 if randf() < 0.5 else -1.0)
	follower.set_meta("path_bias", randf_range(-0.35, 0.35))
	follower.set_meta("path_frequency", 0.75 + randf_range(0.0, 0.25))
#region sacrifice
func can_sacrifice() -> bool:
	return not followers.is_empty() and not is_instance_valid(_sacrificing_follower)

func sacrifice_follower_of_type(type_name: String) -> bool:
	if is_instance_valid(_sacrificing_follower):
		return false

	# Iterate in reverse to find the most recently added follower.
	for i in range(followers.size() - 1, -1, -1):
		var follower = followers[i]
		if is_instance_valid(follower) and follower.get_meta("companion_type", "") == type_name:
			followers.remove_at(i)
			_sacrificing_follower = follower
			_start_sacrifice_animation(follower)
			return true
	return false

func _start_sacrifice_animation(follower: Node2D):
	var tween = create_tween()

	# Reparent the follower to the target so it moves with the player during the animation.
	var original_transform = follower.global_transform
	follower.get_parent().remove_child(follower)
	target.add_child(follower)
	follower.global_transform = original_transform

	var local_mouth_pos = _mouth_pos.position
	var local_pre_mouth_pos = local_mouth_pos + Vector2(60.0 * sign(target.scale.x), 0.0)

	follower.set_physics_process(false)
	follower.set_process(false)

	# Phase 1: Move to staging point.
	tween.tween_property(follower, "position", local_pre_mouth_pos, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Phase 2: Trigger particles, then move to mouth and shrink.
	tween.tween_callback(_trigger_sacrifice_particles)
	tween.tween_property(follower, "position", local_mouth_pos, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(follower, "scale", Vector2.ZERO, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	tween.finished.connect(_on_sacrifice_animation_finished.bind(follower), CONNECT_ONE_SHOT)

func _trigger_sacrifice_particles():
	if not is_instance_valid(_sacrifice_particles):
		return

	# Ensure particles emit from the correct location and set burst properties.
	_sacrifice_particles.position = _mouth_pos.position
	_sacrifice_particles.direction = Vector2.RIGHT

	call_deferred("_emit_particles")

func _emit_particles():
	# This is called deferred to ensure properties are set before emission.
	if not is_instance_valid(_sacrifice_particles):
		return
	_sacrifice_particles.emitting = true

func _on_sacrifice_animation_finished(follower: Node2D):
	if is_instance_valid(follower):
		if follower.has_node("Nutrient"):
			follower.get_node("Nutrient").resolve_extra_effects(target)
		follower.queue_free()
	_sacrificing_follower = null

func remove_follower(follower: Node2D):
	var index = followers.find(follower)
	if index != -1:
		followers.remove_at(index)
		follower.queue_free()
#endregion sacrifice


#region handles movement
func _find_ground_tilemap() -> TileMapLayer:
	# Caches the ground tilemap for performance.
	if is_instance_valid(ground_tilemap_cache):
		return ground_tilemap_cache

	# Using groups is more efficient than searching the entire scene tree.
	# Add your ground TileMapLayer node to a group named "ground_tilemap" in the editor.
	var nodes_in_group = get_tree().get_nodes_in_group("ground_tilemap")
	if not nodes_in_group.is_empty():
		ground_tilemap_cache = nodes_in_group[0] as TileMapLayer
		if is_instance_valid(ground_tilemap_cache):
			return ground_tilemap_cache

	# Fallback: If no group is found, search the scene tree.
	var root = get_tree().current_scene if is_instance_valid(get_tree().current_scene) else get_tree().root
	var queue: Array[Node] = [root]
	while not queue.is_empty():
		var node = queue.pop_front()
		if node is TileMapLayer:
			ground_tilemap_cache = node
			return ground_tilemap_cache
		for child in node.get_children():
			queue.append(child)
	
	return null

func _is_grounded_position(world_pos: Vector2) -> bool:
	var tilemap = _find_ground_tilemap()
	# Prevent error spam if a TileMapLayer without a TileSet is found.
	if not is_instance_valid(tilemap) or not is_instance_valid(tilemap.tile_set):
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
	candidate.y += 15.0
	if _is_grounded_position(candidate):
		candidate.y -= 60.0
	follower.set_meta("orbit_phase", orbit_phase + idle_path_speed * delta * (0.8 + orbit_speed * 0.2))
	return candidate

func _physics_process(delta: float):
	if TimeManager._menu_open_count > 0:
		return

	if Input.is_action_just_pressed("use_companion") and can_sacrifice():
		var last_follower = followers.back()
		if is_instance_valid(last_follower):
			if sacrifice_follower_of_type(last_follower.get_meta("companion_type", "")):
				target.health_component.fully_heal()

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

#endregion
