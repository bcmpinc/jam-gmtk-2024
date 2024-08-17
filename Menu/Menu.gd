extends TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	# Global.music.stream = load("res://Menu/copyright-free-background-music-216517.mp3")
	
	$Platform.pressed.connect(func():
		Global.change_scene_to_file("res://Game/Platformer/World.tscn")
	)
	$Tower.pressed.connect(func():
		Global.change_scene_to_file("res://Game/TowerDefense/TowerDefense.tscn")
	)
