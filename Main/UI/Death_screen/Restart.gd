extends Button
@export var target: Node
@export var next_level:PackedScene
func _ready():
	self.connect("pressed",restart_game)

func restart_game():
	SceneLoader.load_scene(SceneLoader.Scenes.GAME)
