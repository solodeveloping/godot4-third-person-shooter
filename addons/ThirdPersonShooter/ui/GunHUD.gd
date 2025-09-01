extends Control
class_name GunHUD

@onready var weapon_icon_texture_rect: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/WeaponIconTextureRect
@onready var bullet_count_container: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/BulletCountContainer
@onready var current_ammo_label: Label = $PanelContainer/MarginContainer/VBoxContainer/BulletCountContainer/CurrentAmmoLabel
@onready var ammo_backup_label: Label = $PanelContainer/MarginContainer/VBoxContainer/BulletCountContainer/AmmoBackupLabel

var event_bus: ThirdPersonControllerEventBus

func _ready() -> void:
	var current_scene = get_tree().current_scene

	if current_scene.has_node("ThirdPersonControllerEventBus"):
		event_bus = current_scene.get_node("ThirdPersonControllerEventBus")
		
		event_bus.send_current_weapon_changed.connect(_on_event_bus_send_current_weapon_changed)
		event_bus.send_current_ammo_changed.connect(_on_event_bus_send_current_ammo_changed)
		event_bus.send_ammo_backup_changed.connect(_on_event_bus_send_ammo_backup_changed)
	else:
		push_warning("ThirdPersonControllerEventBus not found")

func _on_event_bus_send_current_weapon_changed(current_weapon: WeaponRes):
	if current_weapon != null:
		weapon_icon_texture_rect.texture = current_weapon.icon
	if current_weapon.is_hand_combat:
		bullet_count_container.hide()
	else:
		bullet_count_container.show()

func _on_event_bus_send_current_ammo_changed(current_ammo: int):
	current_ammo_label.text = str(current_ammo)
	
func _on_event_bus_send_ammo_backup_changed(current_ammo_backup: int):
	ammo_backup_label.text = str(current_ammo_backup)
