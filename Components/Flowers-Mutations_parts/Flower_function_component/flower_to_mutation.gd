extends StaticBody2D


# Called when the node enters the scene tree for the first time.
@onready var inventory_node = get_node("/root" + GlobalVar.current_level_name + "Level_editor/Entities_container/Turtle/PlayerComponent/Ui_container/Inventory/Equiped")
	
func done_selecting():
	var mutation_name = GlobalVar.mutation_name_of_flower[name]
	var selected_button = GlobalVar.selected_inventory_slot


	var file_name:String = scene_file_path.get_file()
	selected_button.script_path = scene_file_path.replace(file_name,mutation_name) + ".gd"
	#print(selected_button.script_path)
	
	GlobalVar.source_of_disability.erase("selecting")
	queue_free()

func function_of_object():                             #initialize
	GlobalVar.flower_obtained.append(name)

	inventory_node.is_not_selecting = int(false)

	GlobalVar.source_of_disability.append("selecting")

	inventory_node.connect("selection_is_done",done_selecting)
	#print("connected")
	
