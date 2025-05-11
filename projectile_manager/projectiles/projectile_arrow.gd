extends Area2D
class_name ProjectileArrow

@onready var self_destruct_timer = $SelfDestructTimer

@export var speed := 600.0
var direction := Vector2.RIGHT  # Or LEFT depending on where the player is facing

func _ready():
	#connect("area_entered", _on_area_entered)
	connect("body_entered", _on_body_entered)
	$AnimatedSprite2D.flip_h = true if direction.x < 0 else false
	
	self_destruct_timer.timeout.connect(_on_self_destruct_timeout)

func _process(delta):
	position += direction * speed * delta

"""
func _on_area_entered(area: Area2D) -> void:
	print("area collision")
	if area.is_in_group("enemy") or area.is_in_group("platform"):
		queue_free()
"""

func _on_body_entered(body: Node) -> void:
	#print("body collision")
	#print(body.get_groups())
	if body.is_in_group("enemy"):
		print("arrow hit enemy in projectile_arrow.gd")
		queue_free()
	elif body.is_in_group("platform"):
		print("arrow hit platform in projectile_arrow.gd")
		queue_free()

func _on_self_destruct_timeout():
	queue_free()
