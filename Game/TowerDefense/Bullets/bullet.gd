class_name Bullet extends Node2D

@export var direction : float = 0.0
var speed : float = 10

func _ready() -> void:
	look_at(get_global_mouse_position())

func _process(delta: float) -> void:
	position += transform.x * speed
	position.distance_to(Vector2(160, 240))
	
