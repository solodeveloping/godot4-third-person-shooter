extends SimpleEenemyState

var gravity: float = .98
var max_terminal_velocity: float = 50

var air_speed: float = 8
var air_acceleration: float = 10

func enter():
	enemy.animation_tree.set("parameters/RootState/transition_request", "Falling")

func physics_process(delta: float):
	if enemy.is_on_floor():
		state_machine.transition_to(enemy.state_before_falling)
	else:
		var y_velocity  = lerpf(
			enemy.velocity.y,
			enemy.velocity.y - gravity,
			4 * delta
		)
		y_velocity = clamp(
			enemy.velocity.y - gravity,
			-max_terminal_velocity,
			max_terminal_velocity
		)
		enemy.velocity.y = y_velocity
		enemy.move_and_slide()
