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

@export var crawl_speed = 400.0

### OPDO TODO
# Abilities ODO TODO
# jump + dash: is_jumper 
# same for is_fiighter
# and is_tank
# and that is RADIO!!!!

@export var can_jump: bool = false 
@export var can_dash: bool = false 
@export var can_glide: bool = false 
@export var can_crawl: bool = false
@export var can_hit: bool = false
@export var can_shoot: bool = false

#var velocity: Vector3 = Vector3.ZERO
var is_active: bool = false

### ODO TODO
var facing_direction: int = 0 # right = 1 , left = 0

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

# Crawling Management
@onready var _collision_standing = $CollisionStanding 
@onready var _collision_crawling = $CollisionCrawling
@onready var _hitbox_standing = $HitboxStanding/CollisionShape2D 
@onready var _hitbox_crawling = $HitboxCrawling/CollisionShape2D
@onready var _ceiling_check_area = $CeilingCheck


#tilemap data
#var tilemap: TileMapLayer 

# the animated sprite to show
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var desaturation_shader: Shader
var desaturation_material: ShaderMaterial
@onready var tween: Tween = get_tree().create_tween()


# Health bar
@onready var health_manager = $HealthManager


# Debug label
@onready var label = $Label



### THIS is for AnimatedSprite2D
### ODO TODO: no deed for this if we want AnimationPlayer
#var available_animations: Array[String] = []


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
	
	# initialize crawling: disable and hide crawl state colliders
	_collision_crawling.disabled = true
	_collision_crawling.visible = false
	_hitbox_crawling.disabled = true
	_hitbox_crawling.visible = false

	#THIS is Animated Sprite2D code
	# Ne need if we need AnimationPlayer
	# Populate available animations from the sprite frames resource
	#if animated_sprite.frames:
	#	available_animations = animated_sprite.frames.get_animation_names()
	
	health_manager.take_full_heal()

	
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

### THIS is for AnimatedSprite2D
### ODO TODO: update if we want AnimationPlayer

#var available_animations: Array[String] = []

#func _ready():
	# Populate available animations from the sprite frames resource
	#if animated_sprite.frames:
		#available_animations = animated_sprite.frames.get_animation_names()

#func has_animation(name: String) -> bool:
#	return name in available_animations

#func play_animation(name: String) -> void:
#	#if has_animation(name):
#	animated_sprite.play(name)



"""
func play_animation(name: String) -> void:
	if animated_sprite.has_animation(name):
		animated_sprite.play(name)

func has_animation(name: String) -> bool:
	return animated_sprite.has_animation(name)
"""



func set_crawling(crawling: bool) -> void:
	_collision_standing.disabled = crawling
	_collision_standing.visible = not crawling
	_collision_crawling.disabled = not crawling
	_collision_crawling.visible = crawling
	_hitbox_standing.disabled = crawling
	_hitbox_standing.visible = not crawling
	_hitbox_crawling.disabled = not crawling
	_hitbox_crawling.visible = crawling
	shield_manager.mount_shield(not crawling)
	#if character.has_animation("crawl"):
	if crawling:
		animated_sprite.play("crawl")
	else:
		animated_sprite.play("idle")
	

func can_stand() -> bool:
	return _ceiling_check_area.get_overlapping_bodies().is_empty()

"""
func can_stand() -> bool:
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(40, 128)  # Match your standing shape
	var position = global_position - Vector2(0, 40)  # Above the crawling body

	var params = PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0, position)
	params.collision_mask = 4  # Adjust to detect environment (platforms etc.)

	var result = get_world_2d().direct_space_state.intersect_shape(params)
	print(result)
	return result.is_empty()
"""

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
		
func take_damage(amount: int) -> void:
	print("Player took damage: ", amount)
	health_manager.take_damage(amount)
	# Add health logic here
		

func take_heal(amount: int) -> void:
	print("Player took heal: ", amount)
	health_manager.take_heal(amount)
	
