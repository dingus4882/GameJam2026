extends Control

func _ready() -> void:
	%Button4.visible = !VariableController.is_running_embedded
	%Button4.disabled = VariableController.is_running_embedded

func _credits_pressed ():
	SceneLoader.load_scene(SceneLoader.Scenes.CREDITS)

func _settings_pressed ():
	SceneLoader.load_scene(SceneLoader.Scenes.SETTINGS)

func _game_selection_pressed ():
	SceneLoader.load_scene(SceneLoader.Scenes.GAME)#_SELECTION)

func _end_game_pressed ():
	get_tree().quit()
