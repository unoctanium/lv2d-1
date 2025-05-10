# =========================================
# dash_state.gd
# =========================================
extends CharacterState
class_name DashState

var _dash_timer

func enter():
	_dash_timer = character.dash_timer
	character.velocity.x = character.facing_direction * character.dash_speed
	#print(character.velocity.x)

func physics_update(delta):
	_dash_timer -= delta
	if _dash_timer <= 0.0: #or not character.is_grounded():
		character.velocity.x = 0
		character.state_machine.switch_state("IdleState")
	elif not character.is_grounded():
		character.state_machine.switch_state("FallState")
	#else:
		#character.velocity.y = 0

