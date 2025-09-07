extends Control
class_name GunHUD

# FIXME : reset_size is not working
@onready var v_box_container: VBoxContainer = $PanelContainer/MarginContainer/Control/VBoxContainer

@onready var weapon_icon_texture_rect: TextureRect = $PanelContainer/MarginContainer/Control/VBoxContainer/WeaponIconTextureRect

@onready var bullet_count_container: HBoxContainer = $PanelContainer/MarginContainer/Control/VBoxContainer/BulletCountContainer
@onready var current_ammo_label: Label = $PanelContainer/MarginContainer/Control/VBoxContainer/BulletCountContainer/CurrentAmmoLabel
@onready var ammo_backup_label: Label = $PanelContainer/MarginContainer/Control/VBoxContainer/BulletCountContainer/AmmoBackupLabel


@onready var current_health_label: Label = $PanelContainer/MarginContainer/Control/VBoxContainer/VBoxContainer2/StatContainer/HealthContainer/CurrentHealthLabel

@onready var body_armor_container: HBoxContainer = $PanelContainer/MarginContainer/Control/VBoxContainer/VBoxContainer2/StatContainer/BodyArmorContainer
@onready var current_body_armor_label: Label = $PanelContainer/MarginContainer/Control/VBoxContainer/VBoxContainer2/StatContainer/BodyArmorContainer/CurrentBodyArmorLabel


var event_bus: ThirdPersonControllerEventBus

func _ready() -> void:
	var current_scene = get_tree().current_scene

	if current_scene.has_node("ThirdPersonControllerEventBus"):
		event_bus = current_scene.get_node("ThirdPersonControllerEventBus")
		
		event_bus.send_current_weapon_changed.connect(_on_event_bus_send_current_weapon_changed)
		event_bus.send_current_ammo_changed.connect(_on_event_bus_send_current_ammo_changed)
		event_bus.send_ammo_backup_changed.connect(_on_event_bus_send_ammo_backup_changed)
		
		event_bus.send_current_health_changed.connect(_on_event_bus_send_current_health_changed)
		event_bus.send_current_body_armor_changed.connect(_on_event_bus_send_current_body_armor_changed)
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

func _on_event_bus_send_current_health_changed(new_health: int):
	current_health_label.text = str(new_health)
	
func _on_event_bus_send_current_body_armor_changed(new_body_armor: int):
	current_body_armor_label.text = str(new_body_armor)
	if new_body_armor > 0:
		body_armor_container.show()
	else:
		body_armor_container.hide()
