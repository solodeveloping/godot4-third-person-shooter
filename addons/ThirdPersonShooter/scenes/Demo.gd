extends Node3D

@onready var third_person_controller_event_bus: ThirdPersonControllerEventBus = $ThirdPersonControllerEventBus

@onready var pick_weapon_button_parent: Control = $CanvasLayer/PickWeaponButtonParent

var current_weapon_drop: WeaponDrop
var current_stat_drop: StatDrop

#@onready var path_3d: Path3D = $Path3D
#@onready var path_follow_3d: PathFollow3D = $PathFollow3D


func _ready() -> void:
	pick_weapon_button_parent.hide()

func _on_weapon_drop_container_player_entered_weapon_drop(weapon_drop: WeaponDrop) -> void:
	current_weapon_drop = weapon_drop
	pick_weapon_button_parent.show()
	
	# we are sending the event manually as ane example
	third_person_controller_event_bus.send_player_entered_weapon_drop.emit(
		weapon_drop
	)

func _on_weapon_drop_container_player_exited_weapon_drop(weapon_drop: WeaponDrop) -> void:
	current_weapon_drop = null
	pick_weapon_button_parent.hide()
	
	# we are sending the event manually as ane example
	third_person_controller_event_bus.send_player_exited_weapon_drop.emit(
		weapon_drop
	)

func _on_pickup_weapon_button_button_up() -> void:
	# it cant happen because of the third person view
	pass


func _on_stat_drop_container_player_entered_stat_drop(stat_drop: StatDrop) -> void:
	current_stat_drop = stat_drop
	pick_weapon_button_parent.show()

func _on_stat_drop_container_player_exited_stat_drop(stat_drop: StatDrop) -> void:
	current_stat_drop = null
	pick_weapon_button_parent.hide()
