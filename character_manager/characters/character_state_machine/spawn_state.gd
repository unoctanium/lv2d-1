# =========================================
# spawn_state.gd
# =========================================
extends CharacterState
class_name SpawnState

func enter():
	character.velocity = Vector2.ZERO
	character.state_machine.switch_state("IdleState")

