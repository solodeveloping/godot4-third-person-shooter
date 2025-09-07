extends Object
class_name Ammunition

enum Types {
	LightBullet,
	MediumBullet,
	HeavyBullet,
	Shell,
}

enum DataProps {
	MaxAmmo, BaseDamage,
}

const data = {
	Types.LightBullet: {
		DataProps.MaxAmmo: 500,
		DataProps.BaseDamage: 10,
	},
	Types.MediumBullet: {
		DataProps.MaxAmmo: 300,
		DataProps.BaseDamage: 20,
	},
	Types.HeavyBullet: {
		DataProps.MaxAmmo: 100,
		DataProps.BaseDamage: 100,
	},
	Types.Shell: {
		DataProps.MaxAmmo: 100,
		DataProps.BaseDamage: 50,
	},
}

static func get_damage(ammo_type: Types) -> int:
	if data.has(ammo_type) == false:
		push_error("ammo_type %s not fouhd" % ammo_type)
		return 0
	return data[ammo_type].get(DataProps.BaseDamage, 0)
