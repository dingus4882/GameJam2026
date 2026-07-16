extends Area2D


# Called when the node enters the scene tree for the first time.

func _on_body_entered(body):
	if body.has_node("PlayerComponent"):
		SceneLoader.load_scene(SceneLoader.Scenes.MIMI_BOSS_CUT_SCENE)
