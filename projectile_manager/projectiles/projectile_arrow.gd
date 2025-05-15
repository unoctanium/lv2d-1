extends Area2D
class_name ProjectileArrow

@export_enum("player", "enemy") var source: String = "player"
@onready var self_destruct_timer = $SelfDestructTimer
@export var speed := 600.0
@ecport var damage := 20

var direction := Vector2.RIGHT  # Or LEFT depending on where the player is facing




func _ready():
	connect("area_entered", _on_area_entered)
	connect("body_entered", _on_body_entered)
	
	$AnimatedSprite2D.flip_h = true if direction.x < 0 else false
	self_destruct_timer.timeout.connect(_on_self_destruct_timeout)
	
	if source == "player":
		print("p")
		set_collision_layer_value(7, true) # I am a plkayer bullet
		set_collision_mask_value(8, true) # detecting enemy hitbox
		#
		set_collision_layer_value(6, false)
		set_collision_mask_value(5, false)
		set_collision_mask_value(10, false)
	else:
		print("e")
		set_collision_layer_value(7, false)
		set_collision_mask_value(8, false)
		#
		set_collision_layer_value(6, true) # I am an enemy bullet
		set_collision_mask_value(5, true) # detecting player hitbox 
		set_collision_mask_value(10, false) # and detecting player shields

		

func _process(delta):
	position += direction * speed * delta
	
func _on_area_entered(area: Area2D) -> void:
	if source == "player" and area.is_in_group("enemy"):
		if area.get_parent().has_method("take_damage"):
			area.get_parent().take_damage(damage)
		queue_free()
	elif source == "enemy" and area.is_in_group("player"):
		print(area.name)
		if area.get_parent().has_method("take_damage"):
			area.get_parent().take_damage(damage)
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("platform"):
		#print("arrow hit platform in projectile_arrow.gd")
		queue_free()
	else:
		print("other")
		queue_free()

func _on_self_destruct_timeout():
	queue_free()
