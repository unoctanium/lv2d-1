# =========================================
# crawl_state.gd
# =========================================
extends CharacterState
class_name CrawlState

var allow_exit: bool = false

func enter():
	character.set_crawling(true)
	allow_exit = false

func exit():
	character.set_crawling(false)

func physics_update(delta):
	
		# Try to stand up if the player releases the crawl input
	if character.input_action1 and allow_exit and character.can_stand():
		character.input_action1 = false
		character.state_machine.switch_state("IdleState")
		return
	
	if not character.input_action1:
		allow_exit = true
	
	if not character.is_active:
		character.velocity.x = 0
		return
		
	elif not character.is_grounded():
		character.state_machine.switch_state("FallState")
		return
		
	elif character.is_on_ladder() and character.input_dir.y != 0:
		character.state_machine.switch_state("ClimbState")
		return
		
	elif character.is_on_ladder_top() and character.input_dir.y > 0:
		character.state_machine.switch_state("ClimbState")
		return
		
	elif character.input_dir.x != 0:
		character.velocity.x = character.input_dir.x * character.crawl_speed
		character.velocity.y = 0
		
	else:
		character.velocity.x = 0
		character.velocity.y = 0
		
