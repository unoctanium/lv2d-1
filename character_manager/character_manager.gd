extends Node2D
class_name CharacterManager

signal character_changed(new_character_id)

# Character Scenes
#@export var character_scenes: Array[PackedScene]  # Array of 3 character scenes (templates)
@export var scene_jumper: PackedScene
@export var scene_fighter: PackedScene
@export var scene_tank: PackedScene

var characters: Array[CharacterBase] = []
var active_character_index: int = 0
var active_character: CharacterBase = null

# Character SpawnPoints
#@export var spawn_paths: Array[NodePath]
@export var spawn_jumper: Marker2D
@export var spawn_fighter: Marker2D
@export var spawn_tank: Marker2D
var spawn_points: Array[Marker2D]

# which char shall be active at the beginning
@export var initially_active_index = 0

# Reference to the CameraManager node
@onready var camera_manager: CameraManager = $CameraManager 

# time in sec to transition cam between chars
@export var camera_transition_time = 0.6

# follow speed of cam in px/sec
@export var follow_speed := 10.0

# Boundary that limits the camera movement
@export var tilemap_layer: TileMapLayer = null


# this we need during character initialization
var characters_ready = 0

#shader for all characters
@export var desaturation_shader: Shader

func _ready():

	assert(scene_jumper != null)
	assert(scene_fighter != null)
	assert(scene_tank != null)
	assert(spawn_jumper != null)
	assert(spawn_fighter != null)
	assert(spawn_tank != null)
	assert(desaturation_shader != null)
	assert(tilemap_layer != null)


	# init the cam
	camera_manager.camera_transition_time = camera_transition_time
	camera_manager.set_tilemap(tilemap_layer)
	

	# Spawn the Characters
	var _character: CharacterBase
	
	
	_character = spawn_character(scene_jumper, spawn_jumper, 0)
	_character.can_jump = true
	_character.can_dash = true
	_character.set_collision_layer_value(1, true)
	_character.set_collision_layer_value(2, false)
	_character.set_collision_layer_value(3, false)
	
	_character = spawn_character(scene_fighter, spawn_fighter, 1)
	_character.can_hit = true
	_character.can_shoot = true
	_character.set_collision_layer_value(1, false)
	_character.set_collision_layer_value(2, true)
	_character.set_collision_layer_value(3, false)
	
	
	_character = spawn_character(scene_tank, spawn_tank, 2)
	_character.can_shield = true
	_character.can_glide = true
	_character.shield_manager.has_shield = true
	_character.shield_manager.mount_shield(true)
	_character.set_collision_layer_value(1, false)
	_character.set_collision_layer_value(2, false)
	_character.set_collision_layer_value(3, true)
	_character.set_collision_mask_value(7, false)
	
	
	
	if not characters.size():
		push_error("Error: no characters to spawn for CharacterManager")
		return
	
	set_active_character(initially_active_index, false)


	

func spawn_character(scene_path, spawn_node, index) -> CharacterBase:
	if not (scene_path and spawn_node):
		push_error("Spawn information missing for character index %d" % index)
		return
	
	var character_instance = scene_path.instantiate() as CharacterBase
	#character_instance.character_ready.connect(_on_character_ready)
	character_instance.desaturation_shader = desaturation_shader
	#character_instance.tilemap = tilemap_layer
	character_instance.set_position(spawn_node.get_position())		
	characters.append(character_instance)
	add_child(character_instance)
	return character_instance


#func _on_character_ready():
	#characters_ready += 1
	## this logic only works if I really spawn all 3 characters
	#if characters_ready == 3:
		#set_active_character(initially_active_index, false)


func set_active_character(index: int, smooth: bool):
	if index < 0 or index >= characters.size():
		print("Error: character array oob in CharacterManager")
		return
	
	active_character_index = index
	active_character = characters[index]

	# Tell the CameraManager to follow the new active character
	if camera_manager:
		camera_manager.set_target(active_character, smooth)
	
	# disable input on non-active characters
	for i in range(characters.size()):
		characters[i].set_is_active(i == active_character_index)
		
func change_character():
	var next_index = (active_character_index + 1) % characters.size()
	set_active_character(next_index, true)
	# inform about character change
	character_changed.emit(active_character_index)

func _input(event):
	if event.is_action_pressed("player_select_next"):
		change_character()
