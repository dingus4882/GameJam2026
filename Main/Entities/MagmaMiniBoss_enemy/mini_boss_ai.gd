extends Node

signal attack_done

@onready var base_ai = $".."
@onready var attack_source = $"../../AttackComponent"


@export var action_speed:float = 1
@export var timer:Timer
@export var amount_of_left_point: int
@export var amount_of_right_point: int
var target:CharacterBase
@export var attack_range: Area2D
@export var left_wing:Node
@export var right_wing:Node
@onready var rng_seed:RandomNumberGenerator = RandomNumberGenerator.new()

var is_inside_range := false
# Called when the node enters the scene tree for the first time.
func _ready():
	timer.wait_time = action_speed
	if attack_range != null:
		attack_range.connect("body_entered",player_encounter)
		attack_range.connect("body_exited",player_disengaged)


func player_encounter(_body):
	#print("connected")
	timer.start()
	if timer != null:
		timer.connect("timeout",choose_attack)
		connect("attack_done",timer.start)
	is_inside_range = true
	
	

func player_disengaged(_body):
	timer.stop()
	if timer != null:
		timer.disconnect("timeout",choose_attack)
		disconnect("attack_done",timer.start)
	is_inside_range = false




func set_target_point(where:Node2D, Left_or_Right: String,id: int):
	if where.has_node(Left_or_Right + str(id)):
		
		base_ai.Attack_source.shoot_point = where.get_node(Left_or_Right + str(id))

func camera_shake():
	GlobalAnimation.shake_camera(get_viewport().get_camera_2d())

func skip():
	$"../..".force_stop = true
	
	attack_source.skip_animation_player = true
	attack_source.skip_attack_speed_check = true
	attack_source.skip_shooting_prevention = true
	attack_source.skip_sprite_animation = true

func unskip():
	$"../..".force_stop =false
	
	attack_source.skip_animation_player = false
	attack_source.skip_attack_speed_check = false
	attack_source.skip_shooting_prevention = false
	attack_source.skip_sprite_animation = false
func choose_attack():
	rng_seed.randomize()
	match rng_seed.randi_range(1,3):
		1:
			skip()
			spawn_rock_globo()
			await self.attack_done
			unskip()
		2:
			skip()
			spawn_roller_rock()
			await self.attack_done
			unskip()
		3:
			skip()
			erupt_earth()
			await self.attack_done
			unskip()
	
	
	pass
	
func spawn_rock_globo():
	#print(attack_source.can_fire, "spawn_rock")
	$"../../Cheese_potential".play("Jump_and_slam")
	await $"../../Cheese_potential".animation_finished
	var left = random_fill(1,8,[])
	var right = random_fill(2,8,[])
	
	for i in left:
		set_target_point($"../../Third_attack/Left","Left",i)
		var the_rock = GlobalFunc.instantiate_node("res://Main/Entities/Rock_enemy/glorbo_rock.tscn")
		the_rock.global_position = attack_source.shoot_point.global_position
		$"../..".get_parent().add_child(the_rock)
		
	for i in right:
		set_target_point($"../../Third_attack/Right","Right",i)
		var the_rock = GlobalFunc.instantiate_node("res://Main/Entities/Rock_enemy/glorbo_rock.tscn")
		the_rock.global_position = attack_source.shoot_point.global_position
		$"../..".get_parent().add_child(the_rock)

	
	
	emit_signal("attack_done")
	
func spawn_roller_rock():
	$"../../Cheese_potential".play("Jump_and_slam")
	await $"../../Cheese_potential".animation_finished
	#print(attack_source.can_fire, "roller")
	
	
	emit_signal("attack_done")
	
@export var unique_erupt_earth:int = 0
func erupt_earth():
	match rng_seed.randi_range(1,unique_erupt_earth):
		1:#Checker_board
			#print(attack_source.can_fire, "checker")
			$"../../Cheese_potential".play("Jump_and_slam")
			await $"../../Cheese_potential".animation_finished
			attack_source.currentBullet = attack_source.bullets[2]
			for i in range(1,8,2):
				set_target_point(left_wing,"Left",i)
				attack_source.fire()
				
			for i in range(1,8,2):
				set_target_point(right_wing,"Right",i)
				attack_source.fire()
				
			await get_tree().create_timer(1).timeout
				
			attack_source.currentBullet = attack_source.bullets[1]
			for i in range(1,8,2):
				set_target_point(left_wing,"Left",i)
				attack_source.fire()
			for i in range(1,8,2):
				set_target_point(right_wing,"Right",i)
				attack_source.fire()
		2:#flower
			#print(attack_source.can_fire, "flower")
			$"../../Cheese_potential".play("Jump_and_slam")
			await $"../../Cheese_potential".animation_finished
			attack_source.currentBullet = attack_source.bullets[2]
			for i in range(1,5):
				set_target_point(left_wing,"Left",i)
				attack_source.fire()
				set_target_point(right_wing,"Right",i)
				attack_source.fire()
				await get_tree().create_timer(0.1).timeout
				
			await get_tree().create_timer(0.6).timeout
			
			attack_source.currentBullet = attack_source.bullets[1]
			for i in range(1,5):
				set_target_point(left_wing,"Left",i)
				attack_source.fire()
				set_target_point(right_wing,"Right",i)
				attack_source.fire()
				await get_tree().create_timer(0.1).timeout
		3:#one side then the other
			#print(attack_source.can_fire, "one")
			attack_source.currentBullet = attack_source.bullets[2]
			for i in range(1,5):
				set_target_point(right_wing,"Right",i)
				attack_source.fire()
				
			await get_tree().create_timer(1).timeout
			
			attack_source.currentBullet = attack_source.bullets[1]
			for i in range(1,5):
				set_target_point(right_wing,"Right",i)
				attack_source.fire()
				
			await get_tree().create_timer(1).timeout
			
			attack_source.currentBullet = attack_source.bullets[2]
			for i in range(1,5):
				set_target_point(left_wing,"Left",i)
				attack_source.fire()
			await get_tree().create_timer(1).timeout
			
			attack_source.currentBullet = attack_source.bullets[1]
			for i in range(1,5):
				set_target_point(left_wing,"Left",i)
				attack_source.fire()
				
				
		4:#random
			#print(attack_source.can_fire , "random")
			var left = random_fill(4,8,[])
			var right = random_fill(4,8,[])
			#print(right)
			#print(left)
			attack_source.currentBullet = attack_source.bullets[2]
			for i in right:
				set_target_point(right_wing,"Right",i)
				attack_source.fire()
				await get_tree().create_timer(0.1).timeout
			
			for i in left:
				set_target_point(left_wing,"Left",i)
				attack_source.fire()
				await get_tree().create_timer(0.1).timeout
				
			await get_tree().create_timer(0.6).timeout
			attack_source.currentBullet = attack_source.bullets[1]
			for i in right:
				set_target_point(right_wing,"Right",i)
				attack_source.fire()
				await get_tree().create_timer(0.1).timeout
			
			for i in left:
				set_target_point(left_wing,"Left",i)
				attack_source.fire()
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
