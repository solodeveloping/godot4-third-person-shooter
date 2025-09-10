@tool
extends EditorPlugin

class Action:
	var name: String
	var deadzone: float
	var events: Array[InputEvent]
	
	func _init(name: String, deadzone: float, events: Array[InputEvent]) -> void:
		self.name = name
		self.deadzone = deadzone
		self.events = events 
		
var actions: Array[Action] = [
	Action.new("move_forward", 0.5, [
		build_InputEventKey(KEY_W),
		build_InputEventKey(KEY_UP)
	]),
	Action.new("move_backwards", 0.5, [
		build_InputEventKey(KEY_S),
		build_InputEventKey(KEY_DOWN)
	]),
	Action.new("move_left", 0.5, [
		build_InputEventKey(KEY_A),
		build_InputEventKey(KEY_LEFT)
	]),
	Action.new("move_right", 0.5, [
		build_InputEventKey(KEY_D),
		build_InputEventKey(KEY_RIGHT)
	]),
	Action.new("jump", 0.5, [
		build_InputEventKey(KEY_SPACE),
	]),
	Action.new("zoom_in", 0.5, [
		build_InputEventMouseButton(MOUSE_BUTTON_WHEEL_UP),
	]),
	Action.new("zoom_out", 0.5, [
		build_InputEventMouseButton(MOUSE_BUTTON_WHEEL_DOWN),
	]),
	Action.new("sprint", 0.5, [
		build_InputEventKey(KEY_SHIFT),
	]),
	Action.new("sprint", 0.5, [
		build_InputEventKey(KEY_SHIFT),
	]),
	Action.new("dash", 0.5, [
		build_InputEventKey(KEY_Q),
	]),
	Action.new("crouch", 0.5, [
		build_InputEventKey(KEY_CTRL),
	]),
	Action.new("swim_up", 0.5, [
		build_InputEventKey(KEY_SPACE),
	]),
	Action.new("swim_down", 0.5, [
		build_InputEventKey(KEY_CTRL),
	]),
	Action.new("surge", 0.5, [
		build_InputEventKey(KEY_Q),
	]),
	Action.new("aim", 0.2, [
		build_InputEventMouseButton(MOUSE_BUTTON_RIGHT),
	]),
	Action.new("fire", 0.2, [
		build_InputEventMouseButton(MOUSE_BUTTON_LEFT),
	]),
	Action.new("weapon_1", 0.2, [
		build_InputEventKey(KEY_1),
	]),
	Action.new("weapon_2", 0.2, [
		build_InputEventKey(KEY_2),
	]),
	Action.new("weapon_3", 0.2, [
		build_InputEventKey(KEY_3),
	]),
	Action.new("weapon_4", 0.2, [
		build_InputEventKey(KEY_4),
	]),
	Action.new("weapon_5", 0.2, [
		build_InputEventKey(KEY_5),
	]),
	Action.new("weapon_6", 0.2, [
		build_InputEventKey(KEY_6),
	]),
	Action.new("reload", 0.2, [
		build_InputEventKey(KEY_R),
	]),
	Action.new("pickup_loot", 0.2, [
		build_InputEventKey(KEY_ENTER),
	]),
]

func _enter_tree() -> void:
	var subMenu = PopupMenu.new()
	subMenu.add_item("Add actions to InputMap", 0)
	subMenu.id_pressed.connect(_on_sub_menu_id_pressed)
	add_tool_submenu_item("ThirdPersonShooter", subMenu)

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass

func _on_sub_menu_id_pressed(id: int):
	match id:
		0:
			add_actions_to_input_map()
	
	# WARNING : those are the one from the Editor when running from a tool
	#InputMap.has_action("aim")
	# This make the InputMap behave like it's in game
	# Still have to use the settings though, so far as I know
	# Don't use it, it breaks the editor
	#InputMap.load_from_project_settings()

func add_actions_to_input_map():
	var need_to_save_settings := false
	for action in actions:
		var settings_name = "input/%s" % action.name
		var action_settings = ProjectSettings.get(settings_name)
		var must_set_settings := false
		if action_settings:
			for event in action.events:
				var has_event := false
				for ev in action_settings.events:
					if event is InputEventKey:
						if ev is InputEventKey:
							if event.physical_keycode == ev.physical_keycode:
								has_event = true
								break
					elif event is InputEventMouseButton:
						if ev is InputEventMouseButton:
							if event.button_index == ev.button_index:
								has_event = true
								break
				if !has_event:
					action_settings.events.push_back(event)
					must_set_settings = true
		else:
			must_set_settings = true
			action_settings = {
				deadzone = action.deadzone,
				events = action.events,
			}
		if must_set_settings:
			need_to_save_settings = true
			ProjectSettings.set(settings_name, action_settings)
		else:
			pass
	
	if need_to_save_settings:
		ProjectSettings.save()
		print("Added or updated the actions")
	else:
		print("All the actions are up-to-date")

func build_InputEventKey(
	keycode: int,
) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	
	return event
	
func build_InputEventMouseButton(
	keycode: int
) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = keycode

	return event
