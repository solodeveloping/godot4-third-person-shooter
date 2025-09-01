extends Node
class_name InventorySystem

@export
var weapons_are_unique: bool = true

@export
var bullets_per_type = {
	Ammunition.Types.LightBullet: 0,
	Ammunition.Types.MediumBullet: 0,
	Ammunition.Types.HeavyBullet: 0,
	Ammunition.Types.Shell: 0,
}

var player_inventory: Array[Object] = []

func get_weapon(weapon_index: int):
	if weapon_index >= player_inventory.size():
		return null
	return player_inventory.get(weapon_index)

func add_weapon_or_increase_ammo(weapon_item: WeaponItem):
	if weapons_are_unique == true:
		var weapon_was_present = false
		for item in player_inventory:
			if item == null:
				continue
			if item is WeaponItem:
				if item.weapon == weapon_item.weapon:
					weapon_was_present = true
					bullets_per_type[weapon_item.weapon.ammo_type] += weapon_item.current_mag
		if weapon_was_present == true:
			return
	
	player_inventory.push_back(weapon_item)
	if weapon_item.current_mag > weapon_item.weapon.mag_size:
		var bullets = weapon_item.current_mag - weapon_item.weapon.mag_size
		weapon_item.current_mag = weapon_item.weapon.mag_size
		bullets_per_type[weapon_item.weapon.ammo_type] += bullets

func get_bullet_count(bullet_type: Ammunition.Types) -> int:
	return bullets_per_type.get(bullet_type, 0)
	
## return the amount of bullets removed from inventory
func try_remove_bullets(bullet_type: Ammunition.Types, bullet_count: int) -> int:
	bullets_per_type[bullet_type] -= bullet_count
	
	var bullets = bullet_count
	
	if bullets_per_type[bullet_type] <= 0:
		bullets_per_type[bullet_type] = 0
		bullets_per_type[bullet_type] + bullet_count
	
	return bullets
