# =========================================
# glide_state.gd
# =========================================
extends CharacterState
class_name GlideState

func enter():
	character.velocity.y = min(character.velocity.y, 0)
	
func physics_update(_delta):

	if character.shield_manager.can_glide():
		character.velocity.y += character.glide_gravity 
	
	if not character.is_active:
		if character.is_grounded():
			character.state_machine.switch_state("IdleState")
		return

	elif character.is_on_ladder() and character.input_dir.y:
		character.state_machine.switch_state("ClimbState")
		
	elif character.is_on_ladder_top() and character.input_dir.y > 0:
		character.state_machine.switch_state("ClimbState")

	elif character.is_grounded():
		character.state_machine.switch_state("IdleState")

	elif not character.shield_manager.can_glide():
		character.state_machine.switch_state("FallState")
		
	else:
		character.velocity.x = character.input_dir.x * character.glide_speed 


