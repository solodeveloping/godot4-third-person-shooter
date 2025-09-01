extends Resource
class_name WeaponItem

@export
var current_mag: int
@export
var weapon: WeaponRes

func _init(weapon: WeaponRes = null, mag: int = 0) -> void:
	self.weapon = weapon
	self.current_mag = mag
