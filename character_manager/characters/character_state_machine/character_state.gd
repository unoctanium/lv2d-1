# =========================================
# character_state.gd (Base State Class)
# =========================================
extends Node
class_name CharacterState

@onready var character: CharacterBase = null

func enter():
	pass

func exit():
	pass

func physics_update(_delta):
	pass

func handle_input(_event):
	pass

