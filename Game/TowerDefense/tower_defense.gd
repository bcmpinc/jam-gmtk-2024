extends Node

@onready var bullet = preload("res://Game/TowerDefense/Bullets/Bullet.tscn")

@export var queue : Array[Enemy]

func _ready() -> void:
	for enemy in queue:
		var new_enemy = enemy.duplicate()
		add_child(new_enemy)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("accept"):
		var new_bullet : Bullet = bullet.instantiate()
		new_bullet.position = $Tower.position
		add_child(new_bullet)
