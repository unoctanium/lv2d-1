extends CharacterState
class_name WalkState

func enter():
	character.velocity = Vector2.ZERO

func physics_update(_delta):
	if not character.is_active:
		character.state_machine.switch_state("IdleState")
		return

	elif not character.is_grounded():
		character.state_machine.switch_state("FallState")
		
	elif character.is_on_ladder() and character.input_dir.y != 0:
		character.state_machine.switch_state("ClimbState")
		
	elif character.is_on_ladder_top() and character.input_dir.y > 0:
		character.state_machine.switch_state("ClimbState")
		
	elif character.can_jump and character.input_action1:
		character.state_machine.switch_state("JumpState")

	elif character.can_dash and character.input_action2:
		character.state_machine.switch_state("DashState")
		
	elif character.can_crawl and character.input_action1:
		character.state_machine.switch_state("CrawlState")

	elif character.input_dir.x != 0:
		character.velocity.x = character.input_dir.x * character.speed
		character.velocity.y = 0

	else:
		character.state_machine.switch_state("IdleState")
