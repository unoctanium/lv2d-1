extends Node2D
class_name WeaponManager

# weapon manager needs to be attached to CharacterBody2D player scene to be able to use weapons

@export var arrow_scene: PackedScene
@export var arrow_spawn_offset := Vector2(20, 0)  # Adjust if needed

func shoot_arrow(horizontal_dir: int): # 1 for right, -1 left
	if arrow_scene:
		var arrow = arrow_scene.instantiate()
		var offset = Vector2(arrow_spawn_offset)
		offset.x = offset.x * horizontal_dir
		arrow.global_position = global_position + offset
		arrow.direction = Vector2.LEFT if horizontal_dir < 0 else Vector2.RIGHT
		#Vector2.RIGHT if $Sprite2D.flip_h == false else Vector2.LEFT
		get_tree().current_scene.add_child(arrow)
