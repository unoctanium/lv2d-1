# =========================================
# fall_state.gd
# =========================================
extends CharacterState
class_name FallState

func enter():
	character.velocity.y=0

func physics_update(delta):

	character.velocity.x = lerpf(0, character.velocity.x, pow(2, -3 * delta))
	character.velocity.y += character.gravity.y 
	
	if not character.is_active:
		if character.is_grounded():
			character.state_machine.switch_state("IdleState")
		return

	if character.is_on_ladder() and character.input_dir:
		character.state_machine.switch_state("ClimbState")
		
	elif character.is_on_ladder_top() and character.input_dir.y > 0:
		character.state_machine.switch_state("ClimbState")
		
	elif character.shield_manager.can_glide():
		character.state_machine.switch_state("GlideState")

	elif character.can_jump and character.input_action1:
		character.velocity.x = character.input_dir.x * character.air_speed 
		
	elif character.is_grounded():
		character.state_machine.switch_state("IdleState")

