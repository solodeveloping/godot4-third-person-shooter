extends Node3D
class_name DamageIndicatorManager

const DAMAGE_INDICATOR = preload("res://addons/ThirdPersonShooter/combat/scenes/DamageIndicator.tscn")

var event_bus: ThirdPersonControllerEventBus

func _ready() -> void:
	var current_scene = get_tree().current_scene

	if current_scene.has_node("ThirdPersonControllerEventBus"):
		event_bus = current_scene.get_node("ThirdPersonControllerEventBus")
		
		event_bus.send_damage_enemy.connect(_on_event_bus_send_damage_enemy)
		event_bus.send_damage_player.connect(_on_event_bus_send_damage_player)
		event_bus.send_heal.connect(_on_event_bus_send_heal)
		event_bus.send_body_armor_gain.connect(_on_event_bus_send_body_armor_gain)
	else:
		push_warning("ThirdPersonControllerEventBus not found")

func _on_event_bus_send_damage_enemy(enemy: Node3D, point: Vector3, damage: int, is_critical: bool):
	var instance = DAMAGE_INDICATOR.instantiate()
	instance.damage = damage
	instance.is_critical = is_critical
	
	add_child(instance)
	
	instance.global_position = point

func _on_event_bus_send_damage_player(player: Node3D, point: Vector3, damage: int, is_critical: bool):
	var instance = DAMAGE_INDICATOR.instantiate()
	instance.damage = damage
	instance.is_critical = is_critical
	instance.is_player = true
	
	add_child(instance)
	
	instance.global_position = point

func _on_event_bus_send_heal(node: Node3D, point: Vector3, heal: int, is_critical: bool):
	var instance = DAMAGE_INDICATOR.instantiate()
	instance.heal = heal
	instance.is_critical = is_critical
	
	node.add_child(instance)
	
	instance.global_position = point

func _on_event_bus_send_body_armor_gain(node: Node3D, point: Vector3, heal: int, is_critical: bool):
	var instance = DAMAGE_INDICATOR.instantiate()
	instance.heal = heal
	instance.is_critical = is_critical
	instance.is_body_armor = true
	
	node.add_child(instance)
	
	instance.global_position = point

func remove_indicator(damage_indicator: DamageIndicator):
	remove_child(damage_indicator)
