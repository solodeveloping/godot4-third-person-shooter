extends Resource
class_name EnemyDefResource

@export var walking_speed := 100
@export var running_speed := 250
@export var turn_speed := 01
@export var update_pathfinding_time := 0.5

@export
var model: PackedScene

@export
var rotation_for_model := Vector3(0, 180, 0)

@export
var walking_dist: float = 10

@export
var enable_walking_when_chasing_player: bool = false

@export
var walk_when_patrolling: bool = true

@export var aggro_range: float = 10
@export var use_deaggro_dist := true
@export var deaggro_dist: float = 25
@export var out_of_line_of_sight_follow_time_ms: int = 3000

## If you don't use it, it will detect players in the back
@export
var use_aggro_fow: bool = true

@export
var aggro_fow_deg: float = 70

@export
var attacking_range: float = 20

@export
var attacking_with_gun_fow: float = 10

@export
var ignore_player_when_returning_to_initial_pos := true

@export
var health: int = 100

@export
var max_health: int = 150

@export
var body_armor: int = 0

@export
var max_body_armor: int = 100

@export
var inventory: InventoryResource

@export_flags_3d_physics
var environment_collision_mask: int

@export_flags_3d_physics
var player_collision_mask: int

@export_flags_3d_physics
var player_and_env_collision_mask: int

@export
var gun_attack_rate_limit: float = 0.5

@export
var gun_attack_rate_limit_enabled: bool = true

@export
var extra_volume_db_for_gunshots: float = 0
