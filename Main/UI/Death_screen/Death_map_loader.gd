extends Node

func  _ready() -> void:
	get_parent().connect("died",load_scene)
func load_scene():
	SceneLoader.load_scene(SceneLoader.Scenes.THE_DEATH)
