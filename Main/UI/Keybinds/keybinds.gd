extends Control

@onready var vbox = $Buttons/VBoxContainer
@onready var blueprint = $Buttons/VBoxContainer/Keybind0
@onready var margin_blueprint = $Buttons/VBoxContainer/MarginContainer

var index_to_edit = -1

var actions = [
	"move_left",
	"move_right",
	"jump",
	"esc",
	"fire",
	"use_companion"
]

var action_texts = {
	"move_left": "Move Left",
	"move_right": "Move Right",
	"jump": "Jump",
	"esc": "Cancel",
	"fire": "Attack",
	"use_companion": "Sacrifice"
}

var waiting_for_input = false
var current_action_editing = ""
var keycode_to_edit = 0
var current_editing_button = null
 
const WARNING_LABEL_WIDTH: float = 150.0
var _base_warning_margin_width: float = 0.0
 
func _ready():
	var warning_margin_in_blueprint = blueprint.get_node_or_null("warning_MarginContainer")
	if warning_margin_in_blueprint:
		_base_warning_margin_width = warning_margin_in_blueprint.custom_minimum_size.x
	_setup_keybinds()
	_update_ui_text()
	_check_and_update_warnings()
	_update_all_lines_visibility()

func _setup_keybinds():
	blueprint.visible = false
	
	for action in actions:
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
			
			var slot1 = line * 2 + 0
			var slot2 = line * 2 + 1

			btn1.pressed.connect(func(): _on_change_pressed(action, btn1, slot1))
			btn2.pressed.connect(func(): _on_change_pressed(action, btn2, slot2))
		
		_update_action_labels_for_action(action)

func _update_action_labels_for_action(action: String):
	var keycodes = _get_keycodes_for_action(action)
	
	# Pad with 0s for empty slots to ensure we always have 4 values
	while keycodes.size() < 4:
		keycodes.append(0)

	for line in range(2):
		var item = vbox.get_node_or_null(action + "_" + str(line))
		if item:
			var keycode1 = keycodes[line * 2]
			var keycode2 = keycodes[line * 2 + 1]
			
			item.get_node("input1").text = OS.get_keycode_string(keycode1) if keycode1 != 0 else "---"
			item.get_node("input2").text = OS.get_keycode_string(keycode2) if keycode2 != 0 else "---"
			
			item.get_node("change1").set_meta("keycode", keycode1)
			item.get_node("change2").set_meta("keycode", keycode2)

func _on_change_pressed(action: String, button: Button, slot: int):
	if waiting_for_input:
		return

	waiting_for_input = true
	current_action_editing = action
	keycode_to_edit = button.get_meta("keycode", 0)
	index_to_edit = slot

	current_editing_button = button
	button.text = "..."

func _input(event):
	if waiting_for_input and event is InputEventKey and event.is_released() and not event.is_echo():
		var action_to_update = current_action_editing
		var slot = index_to_edit
		var new_keycode = event.physical_keycode if event.physical_keycode != 0 else event.keycode

		# --- Handle the key press based on the desired logic ---

		# Cancel with Escape
		if new_keycode == KEY_ESCAPE:
			pass
		# Clear with Backspace or Delete
		elif new_keycode == KEY_BACKSPACE or new_keycode == KEY_DELETE:
			if keycode_to_edit != 0:
				VariableController.set_custom_keybind(action_to_update, slot, 0)
		# Remove if the same key is pressed again
		elif new_keycode == keycode_to_edit and keycode_to_edit != 0:
			var current_keys = _get_keycodes_for_action(action_to_update)
			if current_keys.size() > 1:
				VariableController.set_custom_keybind(action_to_update, slot, 0)
		# Add or Replace with a new key
		else:
			VariableController.set_custom_keybind(action_to_update, slot, new_keycode)

		# --- Reset state and update UI ---
		waiting_for_input = false
		current_action_editing = ""
		keycode_to_edit = 0
		index_to_edit = -1
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
	# This function gets all keycodes for a given action directly from the live InputMap.
	# This is the most reliable source of truth for the current state of keybinds,
	# reflecting both defaults and any runtime changes.
	var keys_array: Array[int] = []
	if InputMap.has_action(action):
		# The events are generally returned in the order they were added.
		var events = InputMap.action_get_events(action)
		for event in events:
			if event is InputEventKey:
				var keycode = event.physical_keycode if event.physical_keycode != 0 else event.keycode
				# Ensure the keycode is valid and not already in the list to prevent duplicates.
				if keycode != 0 and not keys_array.has(keycode):
					keys_array.append(keycode)

	return keys_array

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

				if action_has_duplicate:
					# Show warning, shrink margin to its base size.
					warning_label.visible = true
					warning_label.custom_minimum_size.x = WARNING_LABEL_WIDTH
					warning_margin.custom_minimum_size.x = _base_warning_margin_width
				else:
					# Hide warning, expand margin to fill the label's space.
					warning_label.visible = false
					warning_label.custom_minimum_size.x = 0
					warning_margin.custom_minimum_size.x = _base_warning_margin_width + WARNING_LABEL_WIDTH

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
