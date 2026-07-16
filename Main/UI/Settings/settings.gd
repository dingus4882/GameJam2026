extends Control

@onready var music_bar = $"Music Volume"
@onready var sound_bar = $"Sound Volume"

@onready var screen_shake = $ScreenShake

var is_in_game : bool = false

func _ready():
	
	
	is_in_game = get_parent().get_parent().is_in_game
	MusicManager.play_music(MusicManager.MusicType.MENU)

	music_bar.value = VariableController.music
	music_bar.value_changed.connect(_on_music_changed)

	sound_bar.value = VariableController.sound
	sound_bar.value_changed.connect(_on_sound_changed)
	
	if VariableController.screen_shake_enabled:
		screen_shake.text = "Enabled"
	else: screen_shake.text = "Disabled"

func _on_music_changed(new_value: float) -> void:
	VariableController.music = new_value
	MusicManager.update_volume()

func _on_sound_changed(new_value: float) -> void:
	VariableController.sound = new_value
	SoundManager.update_volume()

func ingame_return():
	self.visible = false
func ingame_show():
	self.visible = true

func toggle_screenshake():
	var current = VariableController.screen_shake_enabled
	VariableController.screen_shake_enabled = !current
	if VariableController.screen_shake_enabled:
		screen_shake.text = "Enabled"
	else: screen_shake.text = "Disabled"
