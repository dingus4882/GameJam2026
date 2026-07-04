extends StaticBody2D

@export var main_input: Dialog_tree
# Called when the node enters the scene tree for the first time.
@onready var dialog_component = preload("res://Components/For-Players_parts/Dialog_component/dialog_component.tscn")
@onready var player_sprite = GlobalFunc.get_turtle_location().get_node("Sprite").sprite_frames.get_frame_texture("static",0)

func function_of_object():
	var dialog_instance =  dialog_component.instantiate()
	dialog_instance.dialog_tree = main_input
	dialog_instance.left_side = player_sprite
	dialog_instance.right_side = $Sprite2D.texture
	$"..".get_node("Turtle/PlayerComponent/Ui_container").add_child(dialog_instance)
