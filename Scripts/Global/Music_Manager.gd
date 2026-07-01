extends Node

enum MusicType {
	BOOT_SPLASH,
	LEVEL,
	LOADING,
	MENU
}

var instance: MusicManager
var music_dict: Dictionary = {}
@onready var audio_player = get_node("AudioStreamPlayer")

var current_type: MusicType = MusicType.BOOT_SPLASH
var queued_next_type: MusicType = MusicType.MENU

var last_battle_update_time: int = 0
var is_transitioning: bool = false
var transition_tween: Tween

func _ready():
	_load_sounds()
	audio_player.connect("finished", Callable(self, "_on_audio_finished"))

func _load_sounds():
	for music_type in MusicType.values():
		music_dict[music_type] = []

	music_dict[MusicType.BOOT_SPLASH] += [
		load("res://Assets/Music/TMP_Crown of the Silent Empire_ sunoAI_DO NOT USE.mp3")
	]

	music_dict[MusicType.LEVEL] += [
		load("res://Assets/Music/TMP_Crown of the Silent Empire_ sunoAI_DO NOT USE.mp3"),
		load("res://Assets/Music/TMP_Crown of the Silent Empire_ sunoAI_DO NOT USE.mp3")
	]

	music_dict[MusicType.MENU] += [
		load("res://Assets/Music/TMP_Crown of the Silent Empire_ sunoAI_DO NOT USE.mp3"),
		load("res://Assets/Music/TMP_Crown of the Silent Empire_ sunoAI_DO NOT USE.mp3")
	]

func _process(_delta):
	pass
	#if (current_type == MusicType.BATTLE) and not is_transitioning:
	#	if Time.get_ticks_msec() - last_battle_update_time > 1000:
	#		_fade_to_level_music(2.0)

func play_music(music: MusicType) -> void:
	#if music == MusicType.BATTLE:
	#	last_battle_update_time = Time.get_ticks_msec()
	#	if is_transitioning and (current_type == MusicType.BATTLE):
	#		if transition_tween: transition_tween.kill()
	#		is_transitioning = false
	#		update_volume()
	#		if audio_player.playing:
	#			return

	#var is_requesting_combat = music in [MusicType.BATTLE]
	#var is_current_combat = current_type in [MusicType.BATTLE]

	if (current_type == music) and audio_player.playing:# or (is_requesting_combat and is_current_combat)) and audio_player.playing:
		return

	#if current_type == MusicType.BATTLE:
	#	music = MusicType.BATTLE

	if current_type == MusicType.BOOT_SPLASH:
		music = MusicType.MENU

	if current_type == MusicType.LOADING:
		music = MusicType.LOADING

	# Add more exceptions like top to filter at bottom

	if music == MusicType.LOADING:
		music = current_type

	if current_type == music and audio_player.playing:
		return

	if is_transitioning:
		if transition_tween: transition_tween.kill()
		is_transitioning = false

	current_type = music


	var clips = music_dict.get(music, [])
	if clips.is_empty():
		print("Clip not found: ", music)
		return

	var random_clip = clips[randi() % clips.size()]
	audio_player.stream = random_clip
	audio_player.play()

	audio_player.pitch_scale = 1

	update_volume()

	match music:
		#MusicType.BATTLE:
		#	queued_next_type = MusicType.LEVEL
		_:
			queued_next_type = music

func _fade_to_level_music(duration: float):
	is_transitioning = true
	if transition_tween: transition_tween.kill()
	transition_tween = create_tween()
	transition_tween.tween_property(audio_player, "volume_db", -80.0, duration / 2.0)
	transition_tween.tween_callback(func():
		is_transitioning = false
		play_music(MusicType.LEVEL)
		is_transitioning = true
		audio_player.volume_db = -80.0
		var fade_in = create_tween()
		var target_vol = _get_volume_with_variation() / 100.0
		var target_db = db_from_volume(target_vol)
		fade_in.tween_property(audio_player, "volume_db", target_db, duration / 2.0)
		fade_in.tween_callback(func(): is_transitioning = false)
		transition_tween = fade_in
	)

func _on_audio_finished():
	if queued_next_type != -1:
		play_music(queued_next_type)


static func _get_volume_with_variation() -> float:
	var base_volume = 0.5
	if VariableController != null:
		var vc = VariableController
		base_volume = vc.music
	
	if base_volume <= 0:
		return 0.0
	
	return base_volume

static func db_from_volume(volume: float) -> float:
	if volume <= 0:
		return -80.0  # Complete silence when volume is 0
	return 20 * log(volume) / log(10)

func update_volume():
	var volume = _get_volume_with_variation() / 100
	audio_player.volume_db = db_from_volume(volume)
	# Audio continues playing even when volume is 0 (silent), so it can resume when volume is restored
