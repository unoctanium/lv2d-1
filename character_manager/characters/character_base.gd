# =========================================
# character_base.gd
# =========================================
extends CharacterBody2D
class_name CharacterBase

@export var gravity: Vector2 = Vector2(0.0, 25.0)

@export var initial_facing_right: bool = true

@export var speed: float = 400.0

@export var dash_speed = 900.0
@export var dash_timer = 0.5

@export var glide_speed = 300.0
@export var glide_gravity = 5.0

@export var jump_force: float = -900.0
@export var air_speed = 400.0

# Abilities
@export var can_jump: bool = false
@export var can_dash: bool = false
@export var can_glide: bool = false
@export var can_shield: bool = false
@export var can_hit: bool = false
@export var can_shoot: bool = false

#var velocity: Vector3 = Vector3.ZERO
var is_active: bool = false
var facing_direction: int = 0

# current values from the stick (x=l/r, y=u/d)
var input_dir: Vector2 = Vector2(0.0, 0.0)
var input_action1: bool = false
var input_action2: bool = false

# The StateMachine node with all state children attached
@onready var state_machine: CharacterStateMachine = $CharacterStateMachine

# raytraces to detect ladders
@onready var ray_ladder_down: RayCast2D = $DownCast
@onready var ray_ladder_front: RayCast2D = $FrontCast

# Shield Manager
@onready var shield_manager = $ShieldManager

# WeaponManager
@onready var weapon_manger = $WeaponManager

#tilemap data
#var tilemap: TileMapLayer 

# the animated sprite to show
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var desaturation_shader: Shader
var desaturation_material: ShaderMaterial
@onready var tween: Tween = get_tree().create_tween()

# Debug label
@onready var label = $Label

func _ready():
	# initialize the state machine
	state_machine.initialize(self)
	
	# set the desaturation shader to animate activation and deactivation
	desaturation_material = ShaderMaterial.new()
	desaturation_material.shader = desaturation_shader
	desaturation_material.set("shader_parameter/blend_amount", 1.0)
	animated_sprite.material = desaturation_material
	
	facing_direction = 1 if initial_facing_right else -1
	
	# initialize the weapon manager
	$WeaponManager.face_direction(facing_direction)
	
	# initialize the shield manager
	$ShieldManager.face_direction(facing_direction)
	
	
func _physics_process(delta):
	
	# store current user input for the current frame
	get_user_input()
	
	# Delegate all physics updates to the current state
	if state_machine.current_state:
		state_machine.current_state.physics_update(delta)

	move_and_slide()
	#debug_collisions()
	
	
func debug_collisions():
	# Print all collisions
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		print("Collision ", i, ":")
		print("  - Collider: ", collision.get_collider())
		print("  - Collider RID: ", collision.get_collider_rid())
		print("  - Normal: ", collision.get_normal())
		print("  - Position: ", collision.get_position())
		print("  - Local Shape: ", collision.get_local_shape())
		print("  - Collider Shape: ", collision.get_collider_id())

func _input(_event):
	if is_active:
		input_action1 = Input.is_action_just_pressed("player_action_1")
		input_action2 = Input.is_action_just_pressed("player_action_2")
		
		if input_action2 and can_glide:
			shield_manager.toggle_shield()
			
		if input_action2 and (can_shoot or can_hit):
			weapon_manger.toggle_weapon()
			
		if input_action1 and can_hit:
			weapon_manger.use_weapon(facing_direction)

	else:
		input_action1 = false
		input_action2 = false		

func get_user_input():
	if is_active:
		input_dir = Input.get_vector("player_left", "player_right", "player_up", "player_down")
		if is_zero_approx(input_dir.x):
			input_dir.x = 0
		if is_zero_approx(input_dir.y):
			input_dir.y = 0
	else:
		input_dir = Vector2(0,0)
		
	#facing_direction = sign(input_dir.x)
	if input_dir.x > 0:
		facing_direction = 1
	if input_dir.x < 0:
		facing_direction = -1
	
	update_sprite_flip()



func is_on_ladder() -> bool:
	return ray_ladder_front.is_colliding()

# detect if I am above a glide zone - which will change me to climbstate
func is_on_ladder_top() -> bool:
	return ray_ladder_down.is_colliding()

func is_grounded() -> bool:
	return is_on_floor() or is_on_ladder_top()

func set_is_active(value):
	#if value == is_active:
		#return
	is_active = value
	#animated_sprite.material = null if is_active else grayscale_material
	tween.kill()  # Stop ongoing animations
	if is_active:
		_play_blink_animation(3, 0.1)
		#_fade_to(0.0, 0.5)
	else:
		_fade_to(1.0, 0.5)

func _fade_to(val: float, tim: float):
	desaturation_material.set("shader_parameter/blend_amount", desaturation_material.get("shader_parameter/blend_amount"))
	tween = get_tree().create_tween()
	tween.tween_property(desaturation_material, "shader_parameter/blend_amount", val, tim)

func _play_blink_animation(num_blinks: int, blink_speed: float) -> void:
	if desaturation_material == null:
		push_error("desaturation_material is null.")
		return

	desaturation_material.set_shader_parameter("blend_amount", 1.0)

	tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	for i in range(num_blinks):
		var delay := i * 2 * blink_speed
		tween.tween_property(desaturation_material, "shader_parameter/blend_amount", 0.0, blink_speed).set_delay(delay)
		if i < num_blinks - 1:
			tween.tween_property(desaturation_material, "shader_parameter/blend_amount", 1.0, blink_speed).set_delay(delay + blink_speed)


func update_sprite_flip():
	if facing_direction != 0:
		animated_sprite.flip_h = facing_direction < 0
		
		ray_ladder_front.target_position.x = abs(ray_ladder_front.target_position.x) * facing_direction
		ray_ladder_front.position.x = -abs(ray_ladder_front.position.x) * facing_direction
		
		if shield_manager.has_shield:
			shield_manager.face_direction(facing_direction)
		if weapon_manger.has_hit or weapon_manger.has_shoot:
			weapon_manger.face_direction(facing_direction)
		

		