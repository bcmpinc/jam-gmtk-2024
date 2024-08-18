extends Node

const MAGIC: float = 0.417 * 2

func _ready() -> void:
	for child in get_children():
		if child is Node3D:
			var scale = -child.position.z / 2.0
			print(child.name, ": ", scale)
			child.scale = MAGIC * scale * Vector3.ONE
			child.position.x *= scale
			child.position.y *= scale
