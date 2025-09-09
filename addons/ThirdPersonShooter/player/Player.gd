extends CharacterBody3D

class_name Player

signal movement_state_changed(new_state)

const LOOK_AT_MODIFIER_PATH = "%LookAtModifier3D"
const VFX_DASH_PATH = "VfxDash"
const VFX_SURGE_PATH = "VfxSurge"
const WEAPON_ATTACHMENT_NODE_PATH = "%WeaponAttachmentNode"

@export var max_slope_angle: float = 50
@export var allow_jumping_during_melee_attack: bool = true

@export var override_melee_collision_shape_size: bool = false
@export var melee_collision_shape_size_multiplier: float = 1

@export var model: PackedScene
@export var model_rotation := Vector3(0, 180, 0)

@onready var skin: Node3D = $Skin

@onready var camera: ControllableCamera = $CamRoot/ControllableCamera
@onready var distant_point_front: Node3D = $CamRoot/ControllableCamera/GimbalH/GimbalV/Camera3D/DistantPointFront

@onready var controls: Controls = $Controls
@onready var anim_tree: AnimationTree = $Skin/AnimationTree
@onready var sm_movement: StateMachine = $Movement
@onready var water_surface_detector: Area3D = $WaterSurfaceDetector
@onready var dash_timer: Timer = $DashTimer
@onready var surge_timer: Timer = $SurgeTimer
@onready var weapon_system = $WeaponSystem
@onready var chest_point: Node3D = $ChestPoint

@onready var attack_audio_stream_player_3d: AudioStreamPlayer3D = $AttackAudioStreamPlayer3D
@onready var reload_audio_stream_player_3d: AudioStreamPlayer3D = $ReloadAudioStreamPlayer3D

var horizontal_velocity: Vector3 = Vector3.ZERO
var y_velocity: float = 0
var head_above_water: bool = true
var move_rot: float = 0

var vfx_dash: GPUParticles3D
var vfx_surge: GPUParticles3D
var weapon_attachment_node: Node3D

var extra_forces: Array[ExtraForce] = []

func _ready():
	# watch for changes in the movement state
	sm_movement.connect("transitioned", self._on_move_state_changed)
	
	setup_model()
	
	weapon_system.setup()

func _physics_process(delta):
	# the real velocity is a combination of the horizontal and vertical velocities as determined by
	# the movement state machine
	velocity = Vector3(horizontal_velocity.x, y_velocity, horizontal_velocity.z)
	var time = Time.get_ticks_msec()
	for i in range(extra_forces.size() - 1, -1, -1):
		var extra_force = extra_forces[i]
		if time >= extra_force.apply_until_time_ms:
			extra_forces.remove_at(i)
			continue
		if extra_force.stop_applying_force_on_floor and is_on_floor():
			if time >= extra_force.stop_apply_force_on_floor_time_ms:
				extra_forces.remove_at(i)
				continue
		velocity += extra_force.force
		if extra_force.cancel_gravity:
			velocity.y = extra_force.force.y
	move_and_slide()

func setup_model():
	var instance = model.instantiate()
	skin.add_child(instance)
	if instance is Node3D:
		instance.rotation_degrees = model_rotation
	
	var animation_player = instance.get_node("AnimationPlayer")
	anim_tree.anim_player = animation_player.get_path()
	
	if instance.has_node(VFX_DASH_PATH):
		vfx_dash = instance.get_node(VFX_DASH_PATH)
	if instance.has_node(VFX_SURGE_PATH):
		vfx_surge = instance.get_node(VFX_SURGE_PATH)
	
	if instance.has_node(LOOK_AT_MODIFIER_PATH):
		var look_at_modifier = instance.get_node(LOOK_AT_MODIFIER_PATH)
		if look_at_modifier is LookAtModifier3D:
			look_at_modifier.target_node = distant_point_front.get_path()

	if instance.has_node(WEAPON_ATTACHMENT_NODE_PATH):
		weapon_attachment_node = instance.get_node(WEAPON_ATTACHMENT_NODE_PATH)
	else:
		push_error("WEAPON_ATTACHMENT_NODE_PATH not found")

func _on_DeepWaterDetector_area_entered(area):
	# entered a deep enough water to swim in, transition to the Swimming/Diving state
	sm_movement.transition_to("Swimming/Diving")

func _on_DeepWaterDetector_area_exited(area):
	# exited deep water, transition to the InAir/Falling state
	sm_movement.transition_to("InAir/Falling")

func _on_WaterSurfaceDetector_area_entered(area):
	# the player's head is below the water surface
	head_above_water = false

func _on_WaterSurfaceDetector_area_exited(area):
	# the player's head is above the water surface
	head_above_water = true

func _on_move_state_changed(new_state):
	# trigger the
	emit_signal("movement_state_changed", new_state)
	
func add_extra_force(
	force: Vector3,
	duration_ms: int,
	stop_applying_force_on_floor: bool,
	stop_apply_force_on_floor_delay_ms: int,
	cancel_gravity,
):
	var extra_force = ExtraForce.new()
	extra_force.force = force
	extra_force.apply_until_time_ms = Time.get_ticks_msec() + duration_ms
	extra_force.stop_applying_force_on_floor = stop_applying_force_on_floor
	extra_force.stop_apply_force_on_floor_time_ms = Time.get_ticks_msec() + stop_apply_force_on_floor_delay_ms
	extra_force.cancel_gravity = cancel_gravity
	extra_forces.push_back(extra_force)

func has_movement():
	# the player is fully stopped only if both the movement vector and the velocity
	# vectors are approximately zero. otherwise it means they have movement
	return controls.get_movement_vector() != Vector2.ZERO || !velocity.is_equal_approx(Vector3.ZERO)

func has_weapon() -> bool:
	return weapon_system.has_weapon()

func has_gun() -> bool:
	return weapon_system.has_gun()

func is_attacking() -> bool:
	return weapon_system.is_attacking()

func has_melee_weapon() -> bool:
	return weapon_system.has_melee_weapon()
