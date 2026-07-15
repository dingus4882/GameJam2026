class_name Animated_scene
extends Node2D


@export var animationplayer: AnimationPlayer
@export var start_animation: String = ""


func Start_animation():
	if start_animation != "":
		animationplayer.play(start_animation)
	
func Switch_scene(scene_path):
	SceneLoader.level_dict[SceneLoader.Scenes.GAME] = scene_path
	SceneLoader.load_scene(SceneLoader.Scenes.GAME)


func _ready():
	Start_animation()
