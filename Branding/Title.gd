extends Node

@export var anim  : AnimationPlayer
@export var audio : AudioStreamPlayer
@export_file var next : String

func _ready():
	await get_tree().create_timer(0.8).timeout
	anim.play("Animate")
	audio.play()
	audio.finished.connect(proceed)

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			proceed()

func proceed():
	Global.change_scene_to_file(next)
