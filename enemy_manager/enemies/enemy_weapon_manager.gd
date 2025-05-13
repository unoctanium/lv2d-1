extends Node2D
class_name EnemyWeaponManager

# weapon manager needs to be attached to CharacterBody2D player scene to be able to use weapons

@export var has_shoot = true

@export var arrow_scene: PackedScene
@export var arrow_spawn_offset := Vector2(0,0) #Adjust if needed
@export var shoot_interval := 5.0
var shoot_timer := 0.0

func _ready():
	pass

func _process(delta):
	shoot_timer += delta
	if shoot_timer >= shoot_interval:
		shoot_timer = 0.0
		shoot_arrow(1)

func shoot_arrow(horizontal_dir: int): # 1 for right, -1 left
	if arrow_scene and has_shoot:
		var arrow = arrow_scene.instantiate()
		var offset = Vector2(arrow_spawn_offset)
		offset.x = offset.x * horizontal_dir
		arrow.global_position = global_position + offset
		arrow.direction = Vector2.LEFT if horizontal_dir < 0 else Vector2.RIGHT
		arrow.source = "enemy"
		get_tree().current_scene.add_child(arrow)
