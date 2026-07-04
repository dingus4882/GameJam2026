extends Node

var current_time_scale : float = 0.0
var in_game_elapsed_time : float = 0.0
var in_game : bool = false

func _process(delta):
	if in_game:
		in_game_elapsed_time += delta * current_time_scale #ingame time (time for level or so), could be used for score or countdown

# Time scale control
func pause_speed(): set_time_scale(0.0)
func normal_speed(): set_time_scale(1.0)

func set_time_scale(value: float) -> void:
	if _menu_open_count > 0:
		_saved_time_scale = value
	else:
		current_time_scale = value

# Menu pause
# call if opening a game menu, save a game, quit ,...
var _menu_open_count: int = 0
var _saved_time_scale: float = -1.0
func pause_for_menu() -> void:
	if _menu_open_count == 0:
		_saved_time_scale = current_time_scale
		current_time_scale = 0.0
	_menu_open_count += 1

# call if closing a game menu, save a game, quit ,...
func resume_from_menu() -> void:
	_menu_open_count = max(0, _menu_open_count - 1)
	if _menu_open_count == 0 and _saved_time_scale >= 0.0:
		set_time_scale(_saved_time_scale)
		_saved_time_scale = -1.0
