extends Node2D

@export var max_health: int = 100
#@export var destroy_on_death: bool = false

signal health_changed(current_health: int, max_health: int)
signal died

@onready var health_bar = $HealthBar



var current_health: int = max_health

func _ready():
	current_health = max_health

func take_damage(amount: int) -> void:
	if amount <= 0 or current_health <= 0:
		return

	current_health = max(current_health - amount, 0)
	emit_signal("health_changed", current_health, max_health)

	if current_health == 0:
		die()

func take_heal(amount: int) -> void:
	if amount <= 0 or current_health == max_health:
		return

	current_health = min(current_health + amount, max_health)
	emit_signal("health_changed", current_health, max_health)

func set_health(amount: int):
		if amount <= 0 or current_health == max_health:
			return
		current_health = amount

func take_full_heal() -> void:
	take_heal(max_health)


func die() -> void:
	emit_signal("died")
	#if destroy_on_death:
	#	get_parent().queue_free()

func is_dead() -> bool:
	return current_health <= 0

func get_health_percent() -> float:
	return float(current_health) / float(max_health)
