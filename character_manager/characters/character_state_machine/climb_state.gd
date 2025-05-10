extends CharacterState
class_name ClimbState

func enter():
	character.velocity = Vector2.ZERO

func physics_update(_delta):
	if not character.is_active:
		return

	if not character.is_on_ladder() and not character.is_on_ladder_top():
		character.state_machine.switch_state("FallState")

	elif character.can_jump and character.input_action1:
		character.state_machine.switch_state("JumpState")

	else:
		character.velocity.x = character.input_dir.x * character.speed
		character.velocity.y = character.input_dir.y * character.speed
