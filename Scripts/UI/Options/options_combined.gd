extends Node2D

@onready var settings_btn = $Settings
@export var is_in_game : bool = false
@onready var exit_button = %exit

func _ready():
	# Open settings menu by default
	exit_button.visible = is_in_game
	settings_btn.show_buttons(true)

func _update_ui_text():
	var return_btn = get_node_or_null("Button")
	var keybinds_btn = get_node_or_null("Keybinds")

func _return_pressed():
	if !is_in_game:
		SceneLoader.load_scene(SceneLoader.Scenes.MAIN_MENU)
	else:
		visible = false

func ingame_show():
	visible = true

func _exit_pressed():
	get_parent().get_parent()._exit_tree()
	SceneLoader.load_scene(SceneLoader.Scenes.MAIN_MENU)
