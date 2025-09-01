extends Node3D
class_name WeaponDrop

signal player_entered(weapon_drop: WeaponDrop)
signal player_exited(weapon_drop: WeaponDrop)

@onready var pivot_node: Node3D = $PivotNode
@onready var weapon_parent_node: Node3D = $PivotNode/WeaponParentNode
@onready var area_3d: Area3D = $Area3D

@export var rotation_speed: float = 1.5

@export var override_physics: bool = false

@export_flags_3d_physics
var collision_layer: int

@export_flags_3d_physics
var collision_mask: int

@export
var weapon_item: WeaponItem

@export
var auto_loot := false

func _ready() -> void:
	if override_physics == true:
		area_3d.collision_layer = collision_layer
		area_3d.collision_mask = collision_mask
	
	for child in weapon_parent_node.get_children():
		weapon_parent_node.remove_child(child)
		
	if weapon_item == null:
		push_warning("weapon_item is null")
	else:
		var instance = weapon_item.weapon.scene.instantiate()
		weapon_parent_node.add_child(instance)

func _process(delta: float) -> void:
	pivot_node.rotate(Vector3.UP, rotation_speed * delta)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_entered.emit(self)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_exited.emit(self)
