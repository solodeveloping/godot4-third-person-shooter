extends Node3D
class_name WeaponDropContainer

signal player_entered_weapon_drop(weapon_drop: WeaponDrop)
signal player_exited_weapon_drop(weapon_drop: WeaponDrop)

@export var use_event_bus: bool = false

var event_bus: ThirdPersonControllerEventBus

func _ready() -> void:
	if use_event_bus:
		var current_scene = get_tree().current_scene

		if current_scene.has_node("ThirdPersonControllerEventBus"):
			event_bus = current_scene.get_node("ThirdPersonControllerEventBus")
		else:
			push_warning("ThirdPersonControllerEventBus not found")
	
	for child in get_children():
		if child is WeaponDrop:
			child.player_entered.connect(_on_player_entered_weapon_drop)
			child.player_exited.connect(_on_player_exited_weapon_drop)

func _on_player_entered_weapon_drop(weapon_drop: WeaponDrop):
	player_entered_weapon_drop.emit(weapon_drop)
	if use_event_bus and event_bus:
		event_bus.send_player_entered_weapon_drop.emit(weapon_drop)

func _on_player_exited_weapon_drop(weapon_drop: WeaponDrop):
	player_exited_weapon_drop.emit(weapon_drop)
	if use_event_bus and event_bus:
		event_bus.send_player_exited_weapon_drop.emit(weapon_drop)
