# =========================================
# jump_state.gd
# =========================================
extends CharacterState
class_name JumpState

func enter():
	character.velocity.y = character.jump_force

func physics_update(delta):
	
	character.velocity.x = lerpf(0, character.velocity.x, pow(2, -1 * delta))
	character.velocity.y += character.gravity.y 
	
	if character.velocity.y > 0:
		character.state_machine.switch_state("FallState")
		
	elif not character.is_active:
		return
	
	if character.is_on_ladder() and character.input_dir:
		character.state_machine.switch_state("ClimbState")
		
	elif character.is_on_ladder_top() and character.input_dir.y > 0:
		character.state_machine.switch_state("ClimbState")
		
	else:
		character.velocity.x = character.input_dir.x * character.air_speed 
