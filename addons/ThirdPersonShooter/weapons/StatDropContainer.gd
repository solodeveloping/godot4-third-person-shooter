extends Node3D
class_name StatDropContainer

signal player_entered_stat_drop(stat_drop: StatDrop)
signal player_exited_stat_drop(stat_drop: StatDrop)

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
		if child is StatDrop:
			child.player_entered.connect(_on_player_entered_stat_drop)
			child.player_exited.connect(_on_player_exited_stat_drop)

func _on_player_entered_stat_drop(stat_drop: StatDrop):
	player_entered_stat_drop.emit(stat_drop)
	if use_event_bus and event_bus:
		event_bus.send_player_entered_stat_drop.emit(stat_drop)

func _on_player_exited_stat_drop(stat_drop: StatDrop):
	player_exited_stat_drop.emit(stat_drop)
	if use_event_bus and event_bus:
		event_bus.send_player_exited_stat_drop.emit(stat_drop)
