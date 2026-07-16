class_name Animated_scene
extends Node2D


@export var animationplayer: AnimationPlayer
@export var start_animation: String = ""

@export var end_scene = false

func Start_animation():
	if start_animation != "":
		animationplayer.play(start_animation)
	
func Switch_scene(scene_path):
	if !end_scene:
		SceneLoader.load_scene(SceneLoader.Scenes.MIMI_BOSS_SCENE)
	else:
		SceneLoader.load_scene(SceneLoader.Scenes.GAME_TWO)


func _ready():
	Start_animation()
