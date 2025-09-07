extends Resource
class_name WeaponRes

@export
var scene: PackedScene

@export
var icon: Texture2D

@export
var is_hand_combat: bool = false

@export
var is_melee_weapon: bool = false

@export
var shoot_sfx: AudioStream

@export
var shoot_sfx_volume: float

@export
var spread: float

@export
var movement_spread: float

@export
var aim_spread: float

@export
var crouch_spread: float

@export
var jump_spread: float

@export
var projectile_count: int = 1

@export
var fire_rate: float

@export
var max_range: float = 100.0

@export
var melee_attacking_range: float = 1

@export
var melee_damage_is_physics_based: bool = true

@export
var mag_size: int

@export
var ammo_type: Ammunition.Types

@export
var reload_speed: float

@export
var reload_sfx: AudioStream

@export
var reload_sfx_volume: float

@export
var base_damage: int = 10

@export
var bullet_decal: PackedScene

@export
var muzzle_flash: PackedScene

@export
var bullet_trail: PackedScene

@export
var environment_impact_vfx: PackedScene

@export
var humanoid_impact_vfx: PackedScene
