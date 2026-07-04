extends Node

enum SoundType {
	BUTTON,
	SLIDER,
	NOTIFICATION
}

var instance: SoundManager
var sound_dict: Dictionary = {}
@onready var audio_player = get_node("AudioStreamPlayer")

func _ready():
	_load_sounds()

func _load_sounds():
	sound_dict[SoundType.BUTTON]    = [load("res://Main/SoundAndMusic/Sounds/TMP_ingame_button.wav"),
										load("res://Main/SoundAndMusic/Sounds/TMP_ingame_button (2).wav")]
	sound_dict[SoundType.SLIDER]    = [load("res://Main/SoundAndMusic/Sounds/TMP_ingame_button.wav")]
	sound_dict[SoundType.NOTIFICATION] = [load("res://Main/SoundAndMusic/Sounds/TMP_ingame_button.wav")]

func play_sound(sound: SoundType) -> void:
	if not sound_dict.has(sound):
		_load_sounds()
		if not sound_dict.has(sound):
			return
	
	var clips = sound_dict[sound]
	var random_clip = clips[randi() % clips.size()]
	audio_player.stream = random_clip
	audio_player.play() 

	# Add a random pitch variation
	audio_player.pitch_scale = randf_range(0.95, 1.05)

	update_volume()

static func _get_volume_with_variation() -> float:
	var base_volume = 0.5  # standard volume, if VariableController unused
	if VariableController != null:
		base_volume = VariableController.sound
	
	# If volume is 0, return 0 (no variation applied)
	if base_volume <= 0:
		return 0.0
	
	# Apply variation and clamp between 0 and 100
	return clamp(base_volume + randf_range(0, 10), 0, 100)

static func db_from_volume(volume: float) -> float:
	if volume <= 0:
		return -80.0  # Complete silence when volume is 0
	return 20 * log(volume) / log(10)

func update_volume():
	var volume = _get_volume_with_variation() / 100
	audio_player.volume_db = db_from_volume(volume)
	# Audio continues playing even when volume is 0 (silent), so it can resume when volume is restored
