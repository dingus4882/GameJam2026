extends Control

@onready var vbox = $Buttons/VBoxContainer
@onready var blueprint = $Buttons/VBoxContainer/Keybind0
@onready var margin_blueprint = $Buttons/VBoxContainer/MarginContainer

var actions = [
	"move_left",
	"move_right",
	"jump",
	"esc",
	"fire"
]

var action_texts = {
	"move_left": "Move Left",
	"move_right": "Move Right",
	"jump": "Jump",
	"esc": "Cancel",
	"fire": "Attack"
}

var waiting_for_input = false
var current_action_editing = ""
var current_input_index = 0
var current_editing_button = null

func _ready():
	_setup_keybinds()
	_update_ui_text()
	_check_and_update_warnings()
	_update_all_lines_visibility()

func _setup_keybinds():
	blueprint.visible = false
	
	for action in actions:
		var default_keys = 0
		if InputMap.has_action(action):
			for ev in InputMap.action_get_events(action):
				if ev is InputEventKey: default_keys += 1
		
		var custom = VariableController.custom_keybinds.get(action, [])
		var custom_keys = custom.size() if typeof(custom) == TYPE_ARRAY else 0
		
		# Always create 2 lines per action; visibility will be handled dynamically.
		for line in range(2):
			var item = blueprint.duplicate()
			item.name = action + "_" + str(line)
			item.visible = true
			if line == 0:
				var name_label = item.get_node("name")
				name_label.text = action_texts[action]
			else:
				item.get_node("name").text = ""
			vbox.add_child(item)
			
			var margin = margin_blueprint.duplicate()
			margin.visible = true
			vbox.add_child(margin)
			
			var btn1 = item.get_node("change1")
			var btn2 = item.get_node("change2")
			
			var idx1 = line * 2
			var idx2 = line * 2 + 1
			
			btn1.pressed.connect(func(): _on_change_pressed(action, idx1, btn1))
			btn2.pressed.connect(func(): _on_change_pressed(action, idx2, btn2))
		
		_update_action_labels_for_action(action)

func _update_action_labels_for_action(action: String):
	var keycodes = _get_keycodes_for_action(action)
	var keys = ["---", "---", "---", "---"]
	
	for i in range(min(keycodes.size(), 4)):
		keys[i] = OS.get_keycode_string(keycodes[i])

	for line in range(2):
		var item = vbox.get_node_or_null(action + "_" + str(line))
		if item:
			item.get_node("input1").text = keys[line * 2]
			item.get_node("input2").text = keys[line * 2 + 1]

func _on_change_pressed(action: String, index: int, button: Button):
	if waiting_for_input: return
	
	waiting_for_input = true
	current_action_editing = action
	current_input_index = index
	current_editing_button = button
	button.text = "..."

func _input(event):
	if waiting_for_input and event is InputEventKey and not event.pressed:
		var action_to_update = current_action_editing
		var keycode = event.physical_keycode if event.physical_keycode != 0 else event.keycode
		
		# Cancel with Escape, clear with Backspace or Delete
		if keycode == KEY_ESCAPE:
			pass
		elif keycode == KEY_BACKSPACE or keycode == KEY_DELETE:
			VariableController.set_custom_keybind(action_to_update, current_input_index, 0)
		else:
			VariableController.set_custom_keybind(action_to_update, current_input_index, keycode)
		
		waiting_for_input = false
		current_action_editing = ""
		current_editing_button = null

		_update_ui_text()
		_update_action_labels_for_action(action_to_update)
		_check_and_update_warnings()
		_update_all_lines_visibility()
			
		get_viewport().set_input_as_handled()

func _update_ui_text():
	var edit_text = "menu_edit"
	if edit_text == "menu_edit": edit_text = "Edit"
	
	var title = get_node_or_null("Decorations/Titel")
	if title:
		var t = "menu_keybinds"
		title.text = t if t != "menu_keybinds" else "Keybinds"
	
	var type_label = get_node_or_null("Titles/name")
	if type_label:
		var t = "menu_action"
		type_label.text = t if t != "menu_action" else "Action"
		
	var input1_label = get_node_or_null("Titles/name2")
	if input1_label:
		var t1 = "menu_input1"
		input1_label.text = t1 if t1 != "menu_input1" else "Input 1"

	var input2_label = get_node_or_null("Titles/name4")
	if input2_label:
		var t2 = "menu_input2"
		input2_label.text = t2 if t2 != "menu_input2" else "Input 2"
	
	var duplicate_text = "menu_duplicate_key"
	if duplicate_text == "menu_duplicate_key": duplicate_text = "Duplicate"
	
	for action in actions:
		for line in range(2):
			var item = vbox.get_node_or_null(action + "_" + str(line))
			if item:
				var warning_label = item.get_node_or_null("warning")
				if warning_label:
					warning_label.text = duplicate_text
					
				if line == 0:
					item.get_node("name").text = action_texts.get(action, action.capitalize().replace("_", " "))
				else:
					item.get_node("name").text = ""
					
				# Unconditionally reset button texts. The "..." state is handled separately.
				item.get_node("change1").text = edit_text
				item.get_node("change2").text = edit_text

func _get_keycodes_for_action(action: String) -> Array[int]:
	# This function now correctly merges default keys from the project settings
	# with any custom keys managed by the VariableController. This is necessary
	# because the VariableController may be destructively updating the runtime
	# InputMap, causing default keys to disappear from it.

	var key_set: Dictionary = {}

	# 1. Get default keys directly from ProjectSettings to get a clean, original list.
	var setting_path = "input/" + action
	if ProjectSettings.has_setting(setting_path):
		var action_setting = ProjectSettings.get_setting(setting_path)
		if action_setting is Dictionary and action_setting.has("events") and action_setting["events"] is Array:
			for event in action_setting["events"]:
				if event is InputEventKey:
					var code = event.physical_keycode if event.physical_keycode != 0 else event.keycode
					if code != 0:
						key_set[code] = true

	# 2. Add any custom keys from the controller, ensuring uniqueness.
	if VariableController.custom_keybinds.has(action) and VariableController.custom_keybinds[action] is Array:
		for keycode in VariableController.custom_keybinds[action]:
			if keycode != 0:
				key_set[keycode] = true

	return key_set.keys()

func _check_and_update_warnings():
	var key_to_actions: Dictionary = {} # keycode -> [action_name, ...]

	# 1. Populate key_to_actions map
	for action in actions:
		var keycodes = _get_keycodes_for_action(action)
		for keycode in keycodes:
			if not key_to_actions.has(keycode):
				key_to_actions[keycode] = []
			key_to_actions[keycode].append(action)

	# 2. Find duplicates
	var duplicate_keys: Dictionary = {} # keycode -> [action_name, ...]
	for keycode in key_to_actions:
		if key_to_actions[keycode].size() > 1:
			duplicate_keys[keycode] = key_to_actions[keycode]

	# 3. Update warning labels
	for action in actions:
		var action_has_duplicate = false
		var keycodes = _get_keycodes_for_action(action)
		for keycode in keycodes:
			if duplicate_keys.has(keycode):
				action_has_duplicate = true
				break

		for line in range(2):
			var item = vbox.get_node_or_null(action + "_" + str(line))
			if item:
				var warning_label: Label = item.get_node_or_null("warning")
				var warning_margin: MarginContainer = item.get_node_or_null("warning_MarginContainer")
				if not (warning_label and warning_margin):
					continue

				var is_currently_visible = warning_label.visible
				
				if action_has_duplicate and not is_currently_visible:
					# It was hidden, now it should be visible. Show it and shrink margin.
					warning_label.visible = true
					warning_label.custom_minimum_size.x = 150
					warning_margin.custom_minimum_size.x -= 150
				elif not action_has_duplicate and is_currently_visible:
					# It was visible, now it shouldn't be. Hide it and expand margin.
					warning_label.visible = false
					warning_label.custom_minimum_size.x = 0
					warning_margin.custom_minimum_size.x += 150

func _update_all_lines_visibility():
	for action in actions:
		var keycodes = _get_keycodes_for_action(action)
		
		# Pad the array to make checking easier and have a fixed size
		while keycodes.size() < 4:
			keycodes.append(0)

		var first_line_full = keycodes[0] != 0 and keycodes[1] != 0
		var second_line_has_binds = keycodes[2] != 0 or keycodes[3] != 0
		
		var line2 = vbox.get_node_or_null(action + "_1")
		if line2:
			# The second line is visible if the first is full, or if the second already has binds.
			# This prevents hiding a line that has user-configured keys.
			line2.visible = first_line_full or second_line_has_binds
