extends PlayerState

@export var walk_speed: float = 5
@export var move_speed: float = 10
@export var sprint_speed: float = 14
@export var turn_speed: float = 10
@export var acceleration: float = 50
@export var cam_follow_speed: float = 8

func physics_process(delta):
	# call physics_process method of the the super class (State) which in turn calls the physics_process
	# method of the parent state (the super class is not the same as the parent state)
	super.physics_process(delta)

	# if the player is checked the floor, set their vertical velocity to a miniscule negative value to "snap"
	# them to the ground
	if player.is_on_floor():
		player.y_velocity = -0.01
	else:
		# if not, they're most likely falling of a ledge, so transition into the InAir/Falling state
		state_machine.transition_to("InAir/Falling")
	
	var speed = 0
	if player.controls.is_aiming():
		player.anim_tree.set("parameters/weapon_blend/blend_amount", 1)
		speed = walk_speed
	else:
		player.anim_tree.set("parameters/weapon_blend/blend_amount", 0)
		
		# set the player's horizontal velocity based checked the move or sprint speed
		speed = sprint_speed if player.controls.is_sprinting() else move_speed
	
	if player.has_weapon():
		player.anim_tree.set("parameters/weapon_transition/transition_request", "Armed")
	else:
		player.anim_tree.set("parameters/weapon_transition/transition_request", "Unarmed")
	
	set_horizontal_movement(speed, turn_speed, cam_follow_speed, acceleration, delta)
