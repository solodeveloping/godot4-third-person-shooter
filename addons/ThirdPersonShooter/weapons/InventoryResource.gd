extends Resource
class_name InventoryResource

@export
var infinite_bullets := false

@export
var weapons_are_unique: bool = true

@export
var bullets_per_type = {
	Ammunition.Types.LightBullet: 0,
	Ammunition.Types.MediumBullet: 0,
	Ammunition.Types.HeavyBullet: 0,
	Ammunition.Types.Shell: 0,
}

@export
var content: Array[WeaponItem] = []
