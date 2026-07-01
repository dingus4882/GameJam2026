extends Node2D

@onready var loading_screen_scene = preload("res://Scenes/loading_screen.tscn")

var scene_to_load_path
var loading_screen_instance
var loading = false

var level_dict: Dictionary = {}

enum Scenes {
	MAIN_MENU,
	SETTINGS,
	CREDITS,
	GAME_SELECTION,
	GAME,
}

func _load_scene():
	level_dict[Scenes.MAIN_MENU]					= "res://Scenes/main_menu.tscn"
	level_dict[Scenes.SETTINGS]						= "res://Scenes/UI/options_combined.tscn"
	#level_dict[Scenes.GAME_SELECTION]				= "res://Scenes/UI/game_selection.tscn"
	#level_dict[Scenes.CREDITS]   					= "res://Scenes/UI/credits.tscn"
	level_dict[Scenes.GAME]   						= "res://Scenes/Game/level.tscn"

var active_preloads: Array = []
var unloading_queue: Array = []
var _target_scene_enum: Scenes

var world_generation_progress := 0.0
var scene_loading_progress := 0.0
var wait_for_world_generation := false
var world_generation_done = false
var world_gen_started = false
var world_gen

var scene_progress_final
var _current_progress_frame: float = 0.0
func _ready() -> void:
	scene_progress_final = 0
	world_generation_progress = 0
	_load_scene()

func preload_scene(scene_enum: Scenes):
	var path = level_dict.get(scene_enum)
	if path and not active_preloads.has(path):
		ResourceLoader.load_threaded_request(path)
		active_preloads.append(path)
		if unloading_queue.has(path):
			unloading_queue.erase(path)

func get_scene_load_status(scene_enum: Scenes) -> ResourceLoader.ThreadLoadStatus:
	var path = level_dict.get(scene_enum)
	if path:
		return ResourceLoader.load_threaded_get_status(path)
	return ResourceLoader.THREAD_LOAD_INVALID_RESOURCE

func load_scene(scene_enum: Scenes):
	get_tree().root.gui_disable_input = true
	
	var path = level_dict.get(scene_enum)
	if !path: return

	wait_for_world_generation = (scene_enum == Scenes.GAME)

	# FAST PATH: Instant transition if already fully loaded (skips loading screen visually)
	if not wait_for_world_generation and ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_LOADED:
		if unloading_queue.has(path):
			unloading_queue.erase(path)
		var current_scene = get_tree().current_scene
		var packed_scene = ResourceLoader.load_threaded_get(path)
		var loaded_scene = packed_scene.instantiate()
		
		current_scene.queue_free()
		get_tree().root.add_child(loaded_scene)
		get_tree().current_scene = loaded_scene
		
		get_tree().root.gui_disable_input = false
		_manage_preloads(scene_enum)
		return

	if scene_enum == Scenes.GAME:	MusicManager.play_music(MusicManager.MusicType.LOADING)
	else:	MusicManager.play_music(MusicManager.MusicType.LOADING)
	var current_scene = get_tree().current_scene
	
	_target_scene_enum = scene_enum
	world_gen_started = false
	world_generation_progress = 0.0
	scene_progress_final = 0
	_current_progress_frame = 0.0

	loading_screen_instance = loading_screen_scene.instantiate()
	get_tree().root.call_deferred("add_child", loading_screen_instance)

	#await get_tree().process_frame

	ResourceLoader.load_threaded_request(path)
	if unloading_queue.has(path):
		unloading_queue.erase(path)

	current_scene.queue_free()
	scene_to_load_path = path
	loading = true

	_on_worldgen_status_update("Loading ... 0%")

	world_gen = null

func _process(_delta):
	if unloading_queue.size() > 0:
		for i in range(unloading_queue.size() - 1, -1, -1):
			var path = unloading_queue[i]
			if path == scene_to_load_path and loading:
				unloading_queue.remove_at(i)
				continue
			var p_status = ResourceLoader.load_threaded_get_status(path)
			if p_status == ResourceLoader.THREAD_LOAD_LOADED:
				ResourceLoader.load_threaded_get(path) # Discard reference to free memory
				unloading_queue.remove_at(i)
			elif p_status == ResourceLoader.THREAD_LOAD_FAILED or p_status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				unloading_queue.remove_at(i)

	if not loading:
		return

	var progress_array = []
	var status = ResourceLoader.load_threaded_get_status(scene_to_load_path, progress_array)
	scene_loading_progress = progress_array[0] if progress_array.size() > 0 else 0.0
	
	if scene_progress_final == 1:
		scene_loading_progress = 1.0

	if wait_for_world_generation:
		if loading_screen_instance.find_child("LoadingTexts", true, false).text.contains("Loading"): _on_worldgen_status_update("Loading ... " + str(min(int(scene_loading_progress * 50), 50)) + "%")
	else: _on_worldgen_status_update("Loading ... " + str(min(int(scene_loading_progress * 100), 100)) + "%")

	var combined_progress := 0.0

	if wait_for_world_generation:
		combined_progress = scene_loading_progress * 0.5 + world_generation_progress * 0.5
	else:
		combined_progress = scene_loading_progress

	var target_frame = clampi(int(combined_progress * 100), 0, 100)
	if _current_progress_frame != float(target_frame):
		_current_progress_frame = lerpf(_current_progress_frame, float(target_frame), 5.0 * _delta)
		if abs(_current_progress_frame - float(target_frame)) < 0.5:
			_current_progress_frame = float(target_frame)

	#var progress_sprite = loading_screen_instance.get_node("ProgressBar/AnimatedSprite2D")
	#progress_sprite.frame = clampi(int(round(_current_progress_frame)), 0, 100)

	if status == ResourceLoader.THREAD_LOAD_LOADED:
		scene_progress_final = 1
		var packed_scene = ResourceLoader.load_threaded_get(scene_to_load_path)
		var loaded_scene = packed_scene.instantiate()
		
		get_tree().root.remove_child(loading_screen_instance)
		get_tree().root.add_child(loaded_scene)
		get_tree().root.add_child(loading_screen_instance)
		get_tree().current_scene = loaded_scene
		
		if wait_for_world_generation && !world_gen_started:
			world_gen = loaded_scene
			world_gen.progress_update.connect(_on_worldgen_progress)
			world_gen.status_update.connect(_on_worldgen_status_update)
			world_gen.generation_finished.connect(_on_worldgen_finished)
			world_gen.start_generation()
			world_gen_started = true
		elif !wait_for_world_generation:
			_finalize_scene_loading()
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		_on_worldgen_status_update("Scene loading failed!")
		print("Scene loading failed!")
		get_tree().root.gui_disable_input = false
		loading = false


func _on_worldgen_progress(progress: float):
	world_generation_progress = progress

func _on_worldgen_status_update(text: String):
	if loading_screen_instance:
		var label = loading_screen_instance.find_child("LoadingTexts", true, false)
		if label:
			label.text = text

func _on_worldgen_finished():
	world_generation_progress = 1.0
	world_generation_done = true
	_try_finalize_scene_loading()

func _try_finalize_scene_loading():
	if !world_generation_done:
		return
	_finalize_scene_loading()

func _finalize_scene_loading():
	if world_generation_done || !wait_for_world_generation:
		loading_screen_instance.queue_free()
		loading = false
		await get_tree().process_frame
		get_tree().root.gui_disable_input = false
		if wait_for_world_generation:
			MusicManager.play_music(MusicManager.MusicType.LEVEL)
		
		_manage_preloads(_target_scene_enum)

func _has_sufficient_memory() -> bool:
	if OS.has_method("get_memory_info"):
		var mem_info = OS.get_memory_info()
		if mem_info.has("free") and mem_info["free"] < 1000000000: # Less than 1GB free memory
			return false
	return true

func _manage_preloads(entered_scene: Scenes):
	if not _has_sufficient_memory():
		return
		
	var desired_preloads = []
	var clear_others = false
	
	match entered_scene:
		Scenes.MAIN_MENU:
			desired_preloads = [Scenes.SETTINGS, Scenes.CREDITS, Scenes.GAME_SELECTION]
			clear_others = false
		Scenes.GAME:
			desired_preloads = [Scenes.MAIN_MENU]
			clear_others = true
		Scenes.SETTINGS, Scenes.CREDITS, Scenes.GAME_SELECTION:
			pass # Keep existing preloads to allow quick return to MAIN_MENU
			
	if clear_others:
		for s in level_dict.keys():
			var path = level_dict[s]
			if s not in desired_preloads and s != entered_scene:
				if active_preloads.has(path):
					active_preloads.erase(path)
					if not unloading_queue.has(path):
						unloading_queue.append(path)
						
	for s in desired_preloads:
		preload_scene(s)
