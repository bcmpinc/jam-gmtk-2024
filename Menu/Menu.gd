extends TextureRect

@export_file("*.tscn") var game : String

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.music.stream = load("res://Menu/copyright-free-background-music-216517.mp3")
	ResourceLoader.load_threaded_request(game, "PackedScene")

func _on_button_pressed():
	Global.change_scene_to_file(game)

func _on_rich_text_label_meta_clicked(meta):
	OS.shell_open(meta)
