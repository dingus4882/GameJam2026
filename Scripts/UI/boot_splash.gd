extends Node2D

const INTRO_FPS = 180

var can_continue = false

func _ready() -> void:
	Engine.max_fps = INTRO_FPS
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	MusicManager.play_music(MusicManager.MusicType.BOOT_SPLASH)
	
	SceneLoader.preload_scene(SceneLoader.Scenes.MAIN_MENU)
	
	if not VariableController.has_played_before:
		await %AnimationPlayer.animation_finished

	while SceneLoader.get_scene_load_status(SceneLoader.Scenes.MAIN_MENU) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame

	_show_continue_prompt()

func _show_continue_prompt() -> void:
	can_continue = true

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_viewport().warp_mouse(get_viewport().get_visible_rect().size / 2.0)
	%ContinueLabel.show()

func _input(event: InputEvent) -> void:
	if can_continue and (event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton):
		if event.is_pressed():
			set_process_input(false)
			call_deferred("load_next_scene")

func load_next_scene():
	Engine.max_fps = 0
	if not VariableController.has_played_before:
		VariableController.has_played_before = true
		VariableController.save_settings()

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_viewport().warp_mouse(get_viewport().get_visible_rect().size / 2.0)
	SceneLoader.load_scene(SceneLoader.Scenes.MAIN_MENU)
