extends Node

# Public global variables for sound and music
var sound : int = 50
var old_sound : int = 50
var music : int = 50
var old_music : int = 50

# check if boot splash should play entirely
var has_played_before : bool = false
var old_has_played_before : bool = false

var screen_shake_enabled : bool = true

# keybind changes save
var custom_keybinds : Dictionary = {}
var old_custom_keybinds : Dictionary = {}

# game variables
var difficulty : int = 0
var enemy_advantage_multiplier : int = 1

var isLevelSelected : bool = false

var levelHeight : int = 64
var levelWidth : int = 64

const TILE_SIZE = 32

# game end variables
var last_game_reason = ""
var last_game_won : bool

var elapsed_time = 0 #time it took to complete a level. saved on close level

var is_running_embedded : bool = false

func _ready() -> void:
	is_running_embedded = get_window().is_embedded()
	load_saved_settings()

func _process(_delta: float) -> void:
	if old_music != music || old_sound != sound || old_has_played_before != has_played_before || str(old_custom_keybinds) != str(custom_keybinds):
		save_settings()


func save_settings():
	if !is_running_embedded:
		var config = ConfigFile.new()
		config.set_value("settings", "sound", sound)
		config.set_value("settings", "music", music)
		config.set_value("settings", "has_played_before", has_played_before)
		config.set_value("settings", "custom_keybinds", custom_keybinds)
		config.save("user://settings.cfg")
	
	# Update tracking variables to prevent saving every single frame!
	old_sound = sound
	old_music = music
	old_has_played_before = has_played_before
	old_custom_keybinds = custom_keybinds.duplicate()

func load_saved_settings():
	if !is_running_embedded:
		var config = ConfigFile.new()
		if config.load("user://settings.cfg") == OK:
			music = config.get_value("settings", "music", 50)
			old_music = music
			MusicManager.update_volume()
			sound = config.get_value("settings", "sound", 50)
			old_sound = sound
			SoundManager.update_volume()
			has_played_before = config.get_value("settings", "has_played_before", false)
			old_has_played_before = has_played_before
			
			custom_keybinds = config.get_value("settings", "custom_keybinds", {})
			old_custom_keybinds = custom_keybinds.duplicate()
			apply_custom_keybinds()

func apply_custom_keybinds():
	for action in custom_keybinds:
		if InputMap.has_action(action):
			# Clear existing key events to prevent multiple bindings activating the same action
			var events = InputMap.action_get_events(action)
			for event in events:
				if event is InputEventKey:
					InputMap.action_erase_event(action, event)
			
			# Apply the new custom keycode
			var bind = custom_keybinds[action]
			if typeof(bind) == TYPE_INT: # backwards compatibility
				if bind != 0:
					var new_event = InputEventKey.new()
					new_event.physical_keycode = bind
					InputMap.action_add_event(action, new_event)
			elif typeof(bind) == TYPE_ARRAY:
				for code in bind:
					if typeof(code) == TYPE_INT and code != 0:
						var new_event = InputEventKey.new()
						new_event.physical_keycode = code
						InputMap.action_add_event(action, new_event)

# Use this function in your Keybinds.gd menu script when the user sets a new key!
func set_custom_keybind(action: String, index: int, keycode: int):
	if not custom_keybinds.has(action) or typeof(custom_keybinds[action]) != TYPE_ARRAY:
		var existing = []
		if InputMap.has_action(action):
			for event in InputMap.action_get_events(action):
				if event is InputEventKey:
					existing.append(event.physical_keycode if event.physical_keycode != 0 else event.keycode)
		while existing.size() < 4:
			existing.append(0)
		custom_keybinds[action] = existing.slice(0, 4)
		
	while custom_keybinds[action].size() <= index:
		custom_keybinds[action].append(0)
		
	custom_keybinds[action][index] = keycode
	apply_custom_keybinds()

# add new scene with ingame option toggles?
