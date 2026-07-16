extends Node2D

@export var settings_btn :Control
@export var exit_button :Control

@export var is_in_game : bool = false

@export var root_scene: Node

@export var is_death_scene : bool = false

func _ready():
	if is_death_scene:
		return
	# Open settings menu by default
	exit_button.visible = is_in_game
	if !is_in_game: $Return.text = "Return to Menu"
	settings_btn.show_buttons(true)

func _update_ui_text():
	var return_btn = get_node_or_null("Return")
	var keybinds_btn = get_node_or_null("Keybinds")

func _return_pressed():
	if !is_in_game:
		SceneLoader.load_scene(SceneLoader.Scenes.MAIN_MENU)
	else:
		TimeManager.resume_from_menu()
		visible = false

func ingame_show():
	visible = true
	TimeManager.pause_for_menu()

func _exit_pressed():
	
	TimeManager.resume_from_menu()
	visible = false
	root_scene._exit_tree()
	SceneLoader.load_scene(SceneLoader.Scenes.MAIN_MENU)

func restart_pressed():
	SceneLoader.load_scene(SceneLoader.Scenes.GAME)

func _exit_tree():
	TimeManager.in_game = false
	VariableController.elapsed_time = TimeManager.in_game_elapsed_time
	TimeManager.in_game_elapsed_time = 0
	TimeManager._menu_open_count = 0
	# remove anything, that may stick between games
	pass
	
