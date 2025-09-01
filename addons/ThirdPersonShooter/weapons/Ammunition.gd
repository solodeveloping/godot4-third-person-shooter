extends Object
class_name Ammunition

enum Types {
	LightBullet,
	MediumBullet,
	HeavyBullet,
	Shell,
}

enum DataProps {
	MaxAmmo,
}

const data = {
	Types.LightBullet: {
		DataProps.MaxAmmo: 500,
	},
	Types.MediumBullet: {
		DataProps.MaxAmmo: 300,
	},
	Types.HeavyBullet: {
		DataProps.MaxAmmo: 100,
	},
	Types.Shell: {
		DataProps.MaxAmmo: 100,
	},
}
