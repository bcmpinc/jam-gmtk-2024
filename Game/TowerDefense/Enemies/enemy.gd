class_name Enemy extends Node2D

@export var health : int = 100:
	set(value):
		health = value
		if health < 1:
			die()

@export_enum("small", "medium", "large") var enemy_scale : String = "small"


@export var area : Area2D
@export var collision : CollisionShape2D

func _ready() -> void:
	match enemy_scale:
		"small":
			collision.shape.size = Vector2(32, 32)
		"medium":
			collision.shape.size = Vector2(64, 64)
		"large":
			collision.shape.size = Vector2(128, 128)


func die():
	queue_free()


func _on_enemy_area_area_entered(area: Area2D) -> void:
	var colliding_entity : Node = area.get_parent()
	if colliding_entity is Bullet:
		health -= colliding_entity.damage
		colliding_entity.hit()
