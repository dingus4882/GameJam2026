extends Area2D


# Called when the node enters the scene tree for the first time.

@export var scene_path: String

func _on_body_entered(body):
	if body.has_node("PlayerComponent"):
		SceneLoader.level_dict[SceneLoader.Scenes.GAME] = scene_path
		SceneLoader.load_scene(SceneLoader.Scenes.GAME)
