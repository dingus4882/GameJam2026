extends HealthComponent

var scene
func _ready() -> void:
	self.connect("died",load_scene)
func load_scene():
	SceneLoader.load_scene(SceneLoader.Scenes.THE_DEATH)
