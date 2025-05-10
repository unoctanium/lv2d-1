extends Node2D
class_name CameraManager

@onready var scene_cam: Camera2D = $SceneCamera

var tilemap: TileMapLayer 

var target_character: Node2D
var follow_target := false
var tween: Tween
var camera_transition_time := 0.6
var follow_speed := 10.0

@export var drag_margin: Vector2 = Vector2(80, 60)

var camera_limits: Rect2

func _ready() -> void:
	scene_cam.position_smoothing_enabled = false
	
func _physics_process(delta: float) -> void:
	if follow_target and target_character:
		var target_pos := target_character.global_position
		var cam_pos := scene_cam.global_position

		# Compute drag effect
		var offset := target_pos - cam_pos
		var move := Vector2.ZERO

		if abs(offset.x) > drag_margin.x:
			move.x = offset.x - sign(offset.x) * drag_margin.x
		if abs(offset.y) > drag_margin.y:
			move.y = offset.y - sign(offset.y) * drag_margin.y

		var new_cam_pos = cam_pos + move * follow_speed * delta

		# Apply boundary constraints
		new_cam_pos = _clamp_to_bounds(new_cam_pos)
		scene_cam.global_position = new_cam_pos

func set_tilemap(tilemap_layer: TileMapLayer) -> void:
	tilemap = tilemap_layer
	# Derive camera limits from tilemap or use default
	if tilemap:
		var used_rect = tilemap.get_used_rect()
		var cell_size = tilemap.tile_set.tile_size
		var pos = tilemap.map_to_local(used_rect.position) - cell_size * 0.5
		var size = used_rect.size * cell_size
		camera_limits = Rect2(pos, size)
		#print(camera_limits)
	else:
		camera_limits = Rect2(-100000, -100000, 200000, 200000)


func set_target(character: Node2D, smooth: bool) -> void:
	target_character = character
	follow_target = false

	if tween:
		tween.kill()

	if smooth:
		tween = create_tween()
		tween.tween_property(scene_cam, "global_position", _clamp_to_bounds(character.global_position), camera_transition_time)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_callback(_on_transition_complete)
	else:
		scene_cam.global_position = _clamp_to_bounds(character.global_position)
		follow_target = true

func _on_transition_complete() -> void:
	follow_target = true

func _clamp_to_bounds(pos: Vector2) -> Vector2:
	var screen_size = get_viewport_rect().size
	var half_screen = screen_size * 0.5

	var _min = camera_limits.position + half_screen
	var _max = camera_limits.position + camera_limits.size - half_screen

	return Vector2(
		clamp(pos.x, _min.x, _max.x),
		clamp(pos.y, _min.y, _max.y)
	)
