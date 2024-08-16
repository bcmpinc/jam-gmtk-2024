extends Node2D

@export var direction : float = 0.0
var speed : float = 10
var velocity = 0.0

func _ready() -> void:
	look_at(get_global_mouse_position())

func _process(delta: float) -> void:
	position += transform.x * speed
	pass
