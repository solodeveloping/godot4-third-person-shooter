extends Node
class_name ThirdPersonControllerEventBus

# send: system to UI

signal send_current_weapon_changed(new_weapon: WeaponRes)
signal send_current_ammo_changed(new_ammo_count: int)
signal send_ammo_backup_changed(new_ammo_backup_count: int)

# Drops
signal send_player_entered_weapon_drop(weapon_drop: WeaponDrop)
signal send_player_exited_weapon_drop(weapon_drop: WeaponDrop)
