extends Node

signal attack_done

@onready var base_ai = $".."
@export var Attack_source: AttackComponent


@export var action_speed:float = 1.0
@export var amount_of_left_point: int
@export var amount_of_right_point: int
var target:CharacterBase
@export var attack_range: Area2D
@export var left_wing:Node
@export var right_wing:Node
@onready var rng_seed:RandomNumberGenerator = RandomNumberGenerator.new()


@export var flame_surge:Bullet
@export var warning:Bullet
@export var spawn_rock_glorbo_bullet:Bullet
@export var spawn_roller_bullet:Bullet


@export var time_after_using_rock_spawn:float = 1.0
@export var time_after_using_erupt_earth:float = 1.0
@export var time_after_using_roller:float = 1.0








var is_inside_range := false
# Called when the node enters the scene tree for the first time.
func _ready():

	if attack_range != null:
		attack_range.connect("body_entered",player_encounter)
		attack_range.connect("body_exited",player_disengaged)


func player_encounter(_body):
	#print("connected")
	choose_attack()
	connect("attack_done",choose_attack)
	is_inside_range = true
	
	

func player_disengaged(_body):
	disconnect("attack_done",choose_attack)
	is_inside_range = false




func set_target_point(where:Node2D, Left_or_Right: String,id: int):
	if where.has_node(Left_or_Right + str(id)):
		
		Attack_source.shoot_point = where.get_node(Left_or_Right + str(id))

func camera_shake():
	GlobalAnimation.shake_camera(get_viewport().get_camera_2d())

#func skip():
	#$"../..".force_stop = true
	#
	#Attack_source.skip_animation_player = true
	#Attack_source.skip_attack_speed_check = true
	#Attack_source.skip_shooting_prevention = true
	#Attack_source.skip_sprite_animation = true
	#Attack_source.skip_state_changer = true
#
#func unskip():
	#$"../..".force_stop =false
	#
	#Attack_source.skip_animation_player = false
	#Attack_source.skip_attack_speed_check = false
	#Attack_source.skip_shooting_prevention = false
	#Attack_source.skip_sprite_animation = false
	#Attack_source.skip_state_changer = false
func choose_attack():
	await get_tree().create_timer(action_speed).timeout
	rng_seed.randomize()
	match rng_seed.randi_range(1,3):
		1:
			$"../..".current_state = $"../..".States.ATTACKING
			spawn_rock_globo()
			
			#print("attack")
			await self.attack_done
			await  get_tree().create_timer(time_after_using_rock_spawn).timeout
			#print("done")
			$"../..".current_state = $"../..".States.IDLE
		2:
			$"../..".current_state = $"../..".States.ATTACKING
			spawn_roller_rock()
			#print("attack")
			await self.attack_done
			await  get_tree().create_timer(time_after_using_roller).timeout
			#print("done")
			$"../..".current_state = $"../..".States.IDLE
		3:
			$"../..".current_state = $"../..".States.ATTACKING
			erupt_earth()
			#print("attack")
			await self.attack_done
			#await  get_tree().create_timer(time_after_using_erupt_earth).timeout
			#print("done")
			$"../..".current_state = $"../..".States.IDLE
	
	
	pass
	
func spawn_rock_globo():
	#print(attack_source.can_fire, "spawn_rock")
	$"../../Cheese_potential".play("Jump_and_slam")
	await $"../../Cheese_potential".animation_finished
	var left = random_fill(1,8,[])
	var right = random_fill(2,8,[])
	Attack_source.currentBullet = spawn_rock_glorbo_bullet
	for i in left:
		set_target_point($"../../Third_attack/Left","Left",i)
		Attack_source.fire()
		
	for i in right:
		set_target_point($"../../Third_attack/Left","Left",i)
		Attack_source.fire()

	
	
	emit_signal("attack_done")
	
func spawn_roller_rock():
	$"../../Cheese_potential".play("Jump_and_slam")
	await $"../../Cheese_potential".animation_finished
	#print(attack_source.can_fire, "roller")
	
	
	emit_signal("attack_done")

func print_packet():
	pass
	#print($"../..".current_state)

@export var unique_erupt_earth:int = 0
func erupt_earth():
	match rng_seed.randi_range(1,unique_erupt_earth):
		1:#Checker_board
			#print(attack_source.can_fire, "checker")
			$"../../Cheese_potential".play("Jump_and_slam")
			await $"../../Cheese_potential".animation_finished
			Attack_source.currentBullet = warning
			print_packet()
			for i in range(1,8,2):
				set_target_point(left_wing,"Left",i)
				Attack_source.fire()
			print_packet()
			for i in range(1,8,2):
				set_target_point(right_wing,"Right",i)
				Attack_source.fire()
				
			await get_tree().create_timer(1).timeout
				
			Attack_source.currentBullet = flame_surge
			for i in range(1,8,2):
				set_target_point(left_wing,"Left",i)
				Attack_source.fire()
			for i in range(1,8,2):
				set_target_point(right_wing,"Right",i)
				Attack_source.fire()
			
		2:#flower
			#print(attack_source.can_fire, "flower")
			$"../../Cheese_potential".play("Jump_and_slam")
			await $"../../Cheese_potential".animation_finished
			Attack_source.currentBullet = warning
			print_packet()
			for i in range(1,5):
				set_target_point(left_wing,"Left",i)
				Attack_source.fire()
				set_target_point(right_wing,"Right",i)
				Attack_source.fire()
				await get_tree().create_timer(0.1).timeout
				
			await get_tree().create_timer(0.6).timeout
			print_packet()
			Attack_source.currentBullet = flame_surge
			for i in range(1,5):
				set_target_point(left_wing,"Left",i)
				Attack_source.fire()
				set_target_point(right_wing,"Right",i)
				Attack_source.fire()
				await get_tree().create_timer(0.1).timeout
		3:#one side then the other
			#print(attack_source.can_fire, "one")
			$"../../Cheese_potential".play("Jump_and_slam")
			await $"../../Cheese_potential".animation_finished
			Attack_source.currentBullet = warning
			print_packet()
			for i in range(1,5):
				set_target_point(right_wing,"Right",i)
				Attack_source.fire()
				
			await get_tree().create_timer(1).timeout
			print_packet()
			Attack_source.currentBullet = flame_surge
			for i in range(1,5):
				set_target_point(right_wing,"Right",i)
				Attack_source.fire()
				
			await get_tree().create_timer(1).timeout
			
			Attack_source.currentBullet =warning
			for i in range(1,5):
				set_target_point(left_wing,"Left",i)
				Attack_source.fire()
			await get_tree().create_timer(1).timeout
			
			Attack_source.currentBullet =flame_surge
			for i in range(1,5):
				set_target_point(left_wing,"Left",i)
				Attack_source.fire()
				
				
		4:#random
			#print(Attack_source.can_fire , "random")
			$"../../Cheese_potential".play("Jump_and_slam")
			await $"../../Cheese_potential".animation_finished
			var left = random_fill(4,8,[])
			var right = random_fill(4,8,[])
			#print(right)
			#print(left)
			print_packet()
			Attack_source.currentBullet = warning
			for i in right:
				set_target_point(right_wing,"Right",i)
				Attack_source.fire()
				await get_tree().create_timer(0.1).timeout
			print_packet()
			for i in left:
				set_target_point(left_wing,"Left",i)
				Attack_source.fire()
				await get_tree().create_timer(0.1).timeout
				
			await get_tree().create_timer(0.6).timeout
			Attack_source.currentBullet = flame_surge
			for i in right:
				set_target_point(right_wing,"Right",i)
				Attack_source.fire()
				await get_tree().create_timer(0.1).timeout
			
			for i in left:
				set_target_point(left_wing,"Left",i)
				Attack_source.fire()
				await get_tree().create_timer(0.1).timeout
	emit_signal("attack_done")
func random_fill(roll:int,max_:int,previous_values:Array[int]):
	if roll <= 0:
		return previous_values
	var the_rng = randi_range(1,max_)
	if randi_range(1,max_) in previous_values:
		return random_fill(roll,max_, previous_values)
	previous_values.append(the_rng)
	return random_fill(roll - 1,max_, previous_values)
