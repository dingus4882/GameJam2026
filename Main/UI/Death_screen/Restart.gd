extends Button
@export var target: Node
@export var next_level:PackedScene
func _ready():
	self.connect("pressed",restart_game)

func restart_game():
	GlobalFunc.next_scene(next_level)
