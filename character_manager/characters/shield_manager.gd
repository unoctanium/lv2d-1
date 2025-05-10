extends Node2D
class_name shield_mnager

@onready var front_shield = $FrontShield
@onready var glide_shield = $GlideShield
@onready var front_collision = $FrontShield/CollisionShape2D
@onready var front_sprite = $FrontShield/AnimatedSprite2D
@onready var top_collision = $GlideShield/CollisionShape2D

@export var has_shield: bool = false
var is_shield_top: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_activate_front(false)
	_activate_top(false)
	
func mount_shield(mount: bool) -> void:
	has_shield = mount
	if has_shield:
		switch_shield_front()
	else:
		_activate_front(false)
		_activate_front(false)

func toggle_shield():
	if is_shield_top:
		switch_shield_front()
	else:
		switch_shield_top()

func switch_shield_front():
	if not has_shield:
		return
	is_shield_top = false
	_activate_top(false)
	_activate_front(true)
	
func switch_shield_top():
	if not has_shield:
		return
	is_shield_top = true
	_activate_front(false)
	_activate_top(true)
	
func _activate_front(active: bool):
	$FrontShield.visible = active
	$FrontShield/CollisionShape2D.disabled = not active
	
func _activate_top(active: bool):
	$GlideShield.visible = active
	$GlideShield/CollisionShape2D.disabled = not active
	
func can_glide() -> bool:
	return has_shield and is_shield_top
	
func face_direction(direction: int):
	front_sprite.flip_h = direction < 0
	front_sprite.offset.x = -abs(front_sprite.offset.x) * direction
	front_collision.position.x = abs(front_collision.position.x) *direction
	