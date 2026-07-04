extends Control

var dialog_tree:Dialog_tree
var left_side:Texture2D 
var right_side:Texture2D
var index: int =0
var sprites_state: int = -1:
	set(new_value):
		if new_value != sprites_state:
			sprites_state = new_value
			GlobalFunc.call("play_smoothly" \
			,$Handle_sprites,"left_talking",sprites_state)

# Called when the node enters the scene tree for the first time.


	
@onready var dialog_container = get_node("dialog_box/Label")
# Called when the node enters the scene tree for the first time.
func update(dialog:Dialog_resource):
	
	
	$dialog_box/Label.text = dialog.dialog
	$Handle_txt.play("Text_scroll")
	
	sprites_state = int(dialog.left_or_right)
	
func _ready():
	$Left_side.material = left_side
	$Right_side.material = right_side
	update(dialog_tree.tree[0])
	GlobalVar.source_of_disability.append("dialog_running")
	GlobalAnim.fade_in()




func go_to_next_dialog():
	index +=1
	if index == len(dialog_tree.tree):
		queue_free()
		return
	update(dialog_tree.tree[index])

	
func _on_next_pressed():
	go_to_next_dialog()
func _input(event):
	if event.is_action_pressed("fire"):
		go_to_next_dialog()



func _exit_tree():
	GlobalVar.source_of_disability.erase("dialog_running")
	GlobalAnim.fade_in(true)
