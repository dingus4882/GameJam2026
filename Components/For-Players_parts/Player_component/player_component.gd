class_name PlayerComponent
extends Node2D

@onready var base_node = get_node("..")
# Called when the node enters the scene tree for the first time.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#region disable
	if len(GlobalVar.source_of_disability) > 0:
		return
	#endregion
	
	
	
	#region handles y functions
	if Input.is_action_just_pressed("jump"):
		$"../JumpComponent".jump()
		
	if Input.is_action_pressed("jump"):
		pass
	#endregion
	
	
	base_node.direction = Input.get_axis("move_left", "move_right")
	
	
	
	base_node.movement(delta)
	base_node.animation()
	
	if Input.is_action_pressed("fire"):
		base_node.attack_component.fire()
	
	if Input.is_action_just_pressed("esc"):
		%Ui_container.add_child(GlobalFunc.instantiate_node("res://Main/Ui/Game_menu/game_menu.tscn"))
	
	#print(current_state)
