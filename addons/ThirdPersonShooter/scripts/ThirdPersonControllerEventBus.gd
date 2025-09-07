extends Node
class_name ThirdPersonControllerEventBus

# send: system to UI

# Weapons
signal send_current_weapon_changed(new_weapon: WeaponRes)
signal send_current_ammo_changed(new_ammo_count: int)
signal send_ammo_backup_changed(new_ammo_backup_count: int)

# Weapon VFX
signal send_weapon_vfx_requested(
	global_pos: Vector3,
	scene: PackedScene,
	delay: float,
)

# Drops
signal send_player_entered_weapon_drop(weapon_drop: WeaponDrop)
signal send_player_exited_weapon_drop(weapon_drop: WeaponDrop)

signal send_player_entered_stat_drop(stat_drop: StatDrop)
signal send_player_exited_stat_drop(stat_drop: StatDrop)

# Stats
signal send_current_health_changed(new_health: int)
signal send_current_body_armor_changed(new_body_armor: int)

# Combat
signal send_damage_enemy(enemy: Node3D, point: Vector3, damage: int, is_critical: bool)
signal send_heal(node: Node3D, point: Vector3, heal: int, is_critical: bool)
signal send_body_armor_gain(node: Node3D, point: Vector3, heal: int, is_critical: bool)

signal send_damage_player(player: Node3D, point: Vector3, damage: int, is_critical: bool)

signal send_spawn_bullet_trail(
	scene: PackedScene,
	spawn_global_pos: Vector3,
	target_global_pos: Vector3
)
