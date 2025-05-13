extends Node2D
class_name WeaponManager

# weapon manager needs to be attached to CharacterBody2D player scene to be able to use weapons

@export var has_hit = false
@export var has_shoot = false

@export var hit_top_deg = 55 # -90 + 55 = -35
@export var hit_btm_deg = 145

var _is_mounted_hit = false
var _hit_ready = true

@export var arrow_scene: PackedScene
@export var arrow_spawn_offset := Vector2(20, 0)  # Adjust if needed

@onready var weapon_hit = $WeaponHit
@onready var weapon_shoot = $WeaponShoot
@onready var weapon_hit_anim = $WeaponHit/AnimatedSprite2D
@onready var weapon_shoot_anim = $WeaponShoot/AnimatedSprite2D
@onready var weapon_hit_collider = $WeaponHit/CollisionShape2D

#var character: CharacterBase = null

#func initialize(character_base: CharacterBase):
	#character = character_base

func _ready():
	weapon_hit.connect("area_entered", _on_weapon_hit_area_entered)
	#weapon_hit.visible = false  # Hide visual aid initially
	weapon_hit.rotation_degrees = 0  # Start horizontal
	weapon_hit.monitoring = false
	_show_weapon()
	
func _show_weapon():
	weapon_shoot_anim.visible = has_shoot and not _is_mounted_hit
	weapon_hit_anim.visible = has_hit and _is_mounted_hit
	weapon_hit_collider.visible = has_hit and _is_mounted_hit
	
func mount_hit():
	if not has_hit:
		return
	if _is_mounted_hit:
		return
	_is_mounted_hit = true
	_show_weapon()
	
func mount_shoot():
	if not has_shoot:
		return
	if not _is_mounted_hit:
		return
	_is_mounted_hit = false
	_show_weapon()
	pass
	
func toggle_weapon():
	if not _is_mounted_hit:
		mount_hit()
	else:
		mount_shoot()
	pass
	
func face_direction(direction: int):
	#weapon_hit_anim.flip_v = direction < 0
	#weapon_hit_anim.offset.x = -abs(weapon_hit_anim.offset.x) * direction
	weapon_shoot_anim.flip_h = direction < 0
	weapon_shoot_anim.offset.x = -abs(weapon_shoot_anim.offset.x) * direction
	#weapon_hit_anim.position.x = abs(weapon_hit_anim.position.x) *direction
	weapon_shoot_anim.position.x = abs(weapon_shoot_anim.position.x) *direction
	#weapon_hit_collider.position.x = abs(weapon_hit_collider.position.x) *direction
	#var newbase = -180 if direction < 0 else 0
	#weapon_hit.rotation_degrees = -35 * direction
	#var hit_delta = 90 + weapon_hit.rotation_degrees
	#weapon_hit.rotation_degrees = weapon_hit.rotation_degrees + hit_delta * direction 
	weapon_hit.rotation_degrees = -90.0 + hit_top_deg * (-1 if direction < 0 else 1)
	
func use_weapon(horizontal_dir: int):
	if _is_mounted_hit:
		hit_sword(horizontal_dir)
	else:
		shoot_arrow(horizontal_dir)

func shoot_arrow(horizontal_dir: int): # 1 for right, -1 left
	if arrow_scene and has_shoot:
		if _is_mounted_hit:
			mount_shoot()
		var arrow = arrow_scene.instantiate()
		var offset = Vector2(arrow_spawn_offset)
		offset.x = offset.x * horizontal_dir
		arrow.global_position = global_position + offset
		arrow.direction = Vector2.LEFT if horizontal_dir < 0 else Vector2.RIGHT
		arrow.source = "player"
		get_tree().current_scene.add_child(arrow)
		
func hit_sword(horizontal_dir: int): # 1 for right, -1 left
	if not has_hit:
		return
	if not _is_mounted_hit:
		mount_hit()
	
	if not _hit_ready:
		return

	_hit_ready = false
	#weapon_hit.visible = true
	weapon_hit.monitoring = true

	var tween = create_tween()
	#tween.tween_property(weapon_hit, "rotation_degrees", -30 * horizontal_dir, 0.1)
	tween.tween_property(weapon_hit, "rotation_degrees", -90.0 + hit_btm_deg * (-1 if horizontal_dir < 0 else 1) , 0.15)
	tween.tween_property(weapon_hit, "rotation_degrees", -90.0 + hit_top_deg * (-1 if horizontal_dir < 0 else 1)
	, 0.01)
	tween.tween_callback(_on_sword_swing_complete)
	
func _on_weapon_hit_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		if area.get_parent().has_method("take_damage"):
			area.get_parent().take_damage(10)
		#print("Enemy hit!")

func _on_sword_swing_complete() -> void:
	#weapon_hit.visible = false
	weapon_hit.monitoring = false
	_hit_ready = true
