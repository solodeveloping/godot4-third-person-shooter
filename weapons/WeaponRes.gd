extends Resource
class_name WeaponRes

@export
var scene: PackedScene

@export
var icon: Texture2D

@export
var is_hand_combat: bool = false

@export
var shoot_sfx: AudioStream

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
var fire_rate: int

@export
var mag_size: int

@export
var ammo_type: Ammunition.Types

@export
var reload_speed: float

@export
var reload_sfx: AudioStream
