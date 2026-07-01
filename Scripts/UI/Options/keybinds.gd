extends Control

@onready var vbox = $Buttons/VBoxContainer
@onready var blueprint = $Buttons/VBoxContainer/Keybind0
@onready var margin_blueprint = $Buttons/VBoxContainer/MarginContainer

var actions = [
	"open_map",
	"ui_cancel",
	"inventory",
	"storage"
]

var action_texts = {
	"open_map": "Open Map",
	"ui_cancel": "Cancel",
	"inventory": "Inventory",
	"storage" : "Storage"
}

var waiting_for_input = false
var current_action_editing = ""
var current_input_index = 0
var current_editing_button = null

func _ready():
	_setup_keybinds()
	_update_ui_text()
	_check_and_update_warnings()

func _setup_keybinds():
	blueprint.visible = false
	
	for action in actions:
		var default_keys = 0
		if InputMap.has_action(action):
			for ev in InputMap.action_get_events(action):
				if ev is InputEventKey: default_keys += 1
		
		var custom = VariableController.custom_keybinds.get(action, [])
		var custom_keys = custom.size() if typeof(custom) == TYPE_ARRAY else 0
		
		var lines = 1
		if default_keys > 2 or custom_keys > 2:
			lines = 2
			
		for line in range(lines):
			var item = blueprint.duplicate()
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
	var keys = ["---", "---", "---", "---"]
	
	if VariableController.custom_keybinds.has(action) and typeof(VariableController.custom_keybinds[action]) == TYPE_ARRAY:
		var binds = VariableController.custom_keybinds[action]
		for i in range(min(binds.size(), 4)):
			if typeof(binds[i]) == TYPE_INT and binds[i] != 0:
				keys[i] = OS.get_keycode_string(binds[i])
	else:
		if InputMap.has_action(action):
			var events = InputMap.action_get_events(action)
			var idx = 0
			for event in events:
				if event is InputEventKey and idx < 4:
					var code = event.physical_keycode if event.physical_keycode != 0 else event.keycode
					if code != 0:
						keys[idx] = OS.get_keycode_string(code)
						idx += 1

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
		var keycode = event.physical_keycode if event.physical_keycode != 0 else event.keycode
		
		# Cancel with Escape, clear with Backspace or Delete
		if keycode == KEY_ESCAPE:
			pass
		elif keycode == KEY_BACKSPACE or keycode == KEY_DELETE:
			VariableController.set_custom_keybind(current_action_editing, current_input_index, 0)
		else:
			VariableController.set_custom_keybind(current_action_editing, current_input_index, keycode)
		
		waiting_for_input = false
		
		var edit_text = ""
		current_editing_button.text = edit_text if edit_text != "menu_edit" else "Edit"
		
		_update_action_labels_for_action(current_action_editing)
		_check_and_update_warnings()
			
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
		
	var input1_label = get_node_or_null("Titles/input1")
	if input1_label:
		var t1 = "menu_input1"
		input1_label.text = t1 if t1 != "menu_input1" else "Input 1"

	var input2_label = get_node_or_null("Titles/input2")
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
					var name_label = item.get_node("name")
					var t_key = "action_" + action
					var translated = ""
					if translated == t_key: # Backup generator if key missing
						translated = action.capitalize().replace("_", " ")
					name_label.text = translated
				else:
					item.get_node("name").text = ""
					
				if current_action_editing != action or current_input_index != (line * 2):
					item.get_node("change1").text = edit_text
				if current_action_editing != action or current_input_index != (line * 2 + 1):
					item.get_node("change2").text = edit_text

func _get_keycodes_for_action(action: String) -> Array[int]:
	var keycodes: Array[int] = []
	
	if VariableController.custom_keybinds.has(action) and typeof(VariableController.custom_keybinds[action]) == TYPE_ARRAY:
		var binds = VariableController.custom_keybinds[action]
		for i in range(binds.size()):
			if typeof(binds[i]) == TYPE_INT and binds[i] != 0:
				keycodes.append(binds[i])
	else:
		if InputMap.has_action(action):
			var events = InputMap.action_get_events(action)
			for event in events:
				if event is InputEventKey:
					var code = event.physical_keycode if event.physical_keycode != 0 else event.keycode
					if code != 0:
						keycodes.append(code)
	return keycodes

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
				var warning_label = item.get_node_or_null("warning") as Label
				var margin_container = item.get_node_or_null("MarginContainer") as MarginContainer
				if warning_label and margin_container:
					warning_label.visible = action_has_duplicate
					if action_has_duplicate:
						margin_container.custom_minimum_size.x = 50
					else:
						# Add the warning label's width (150) to the margin's base width (50)
						margin_container.custom_minimum_size.x = 200
