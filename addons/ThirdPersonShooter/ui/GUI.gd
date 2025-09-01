extends CanvasLayer

@onready var pickup_weapon_button: Button = $PickWeaponButtonParent/PickupWeaponButton

func _ready() -> void:
	var inputs: Array[InputEvent] = InputMap.action_get_events("pickup_loot")
	if inputs.size() > 0:
		var input = inputs[0]
		pickup_weapon_button.text = "press [%s] to pick up" % OS.get_keycode_string(input.physical_keycode)
