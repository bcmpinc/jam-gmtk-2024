extends Node

@export var cam : Camera2D
@export var player : CharacterBody2D

func _ready() -> void:
	cam.position = player.position
	

func _process(delta: float) -> void:
	cam.position = lerp(cam.position, player.camera_center.global_position, 18*delta)
	
