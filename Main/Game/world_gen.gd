extends Node2D

signal progress_update(progress: float) # progress from 0.0 to 1.0
signal status_update(text: String)
signal generation_finished()

var generation_started := false

@onready var options = %Options
@onready var fps_label  = $FPS_COUNTER # for debug only or checking frames overall
var update_timer := 0.0

@export var enemy : CharacterBody2D
var was_alive : bool = false

func _process(delta: float) -> void:
	update_timer += delta
	delta *= TimeManager.current_time_scale
	
	if was_alive && enemy.health_component.is_dead:
		was_alive = false
		_load_next_scene_with_delay(2.0)
	
	if fps_label: #update_timer >= 0.5:
		#update_timer = 0.0
		var fps := Engine.get_frames_per_second()
		fps_label.text = "%d" % fps + " FPS"
		
		if fps < 30:
			fps_label.add_theme_color_override("font_color", Color.RED)
		elif fps < 60:
			fps_label.add_theme_color_override("font_color", Color.YELLOW)
		else:
			fps_label.add_theme_color_override("font_color", Color.GREEN)


func _load_next_scene_with_delay(delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	SceneLoader.load_scene(SceneLoader.Scenes.GAME_TWO)

const CHUNK_SIZE = 64
var num_chunks_x = 1
var num_chunks_y = 1
var total_chunks := 0
var processed_chunks := 0.0

func _ready():
	# Disable all UI/Button interactions globally
	get_tree().root.gui_disable_input = true
	MusicManager.play_music(MusicManager.MusicType.LEVEL)
	
	if enemy:
		was_alive = true

func _exit_tree():
	TimeManager.in_game = false
	VariableController.elapsed_time = TimeManager.in_game_elapsed_time
	TimeManager.in_game_elapsed_time = 0
	TimeManager._menu_open_count = 0
	# remove anything, that may stick between games
	pass

func start_generation():
	
	num_chunks_x = 1 # fit to new system
	num_chunks_y = 1

	if generation_started:
		return

	generation_started = true
	await get_tree().process_frame

	# create world, if not prebuild levels

	await get_tree().process_frame
	generate_world()

func _on_scene_loader_update(text: String):
	emit_signal("status_update", text)

func generate_world():
	TimeManager.pause_speed()

	_on_scene_loader_update("Loading Terrain")
	await get_tree().process_frame

	total_chunks = num_chunks_x * num_chunks_y * 2
	processed_chunks = 0
	await get_tree().process_frame
	
	# load chunks if they exist
	processed_chunks = total_chunks
	emit_signal("progress_update", float(processed_chunks) / total_chunks)
	_on_all_chunks_done()


func _on_all_chunks_done():
	processed_chunks += num_chunks_x * num_chunks_y * .25
	emit_signal("progress_update", float(processed_chunks) / total_chunks)

	processed_chunks += num_chunks_x * num_chunks_y * .25
	emit_signal("progress_update", float(processed_chunks) / total_chunks)
	await get_tree().process_frame

	processed_chunks += num_chunks_x * num_chunks_y * .25
	emit_signal("progress_update", float(processed_chunks) / total_chunks)
	await get_tree().process_frame

	await get_tree().process_frame
	emit_signal("generation_finished")
	TimeManager.normal_speed()
	TimeManager.in_game = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		options.ingame_show()
