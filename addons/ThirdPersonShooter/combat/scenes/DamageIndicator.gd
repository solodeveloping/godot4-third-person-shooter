extends Node3D
class_name DamageIndicator

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var label_3d: Label3D = $Node3D/Label3D
@onready var timer: Timer = $Timer

var is_critical: bool = false
var is_body_armor: bool = false
var damage: int = 0
var heal: int = 0
var is_player: bool = false

func _ready() -> void:
	if damage > 0:
		if is_player:
			label_3d.text = "-" + str(damage)
		else:
			label_3d.text = str(damage)
		if is_critical:
			animation_player.play("critical_damage")
		else:
			animation_player.play("normal_damage")
	elif heal > 0:
		label_3d.text = str(heal)
		if is_body_armor:
			animation_player.play("normal_body_armor")
		else:
			animation_player.play("normal_heal")
		
	timer.start()

func _on_timer_timeout() -> void:
	if get_parent().is_in_group("player"):
		get_parent().remove_child(self)
	else:
		get_parent().remove_indicator(self)
