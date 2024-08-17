extends Node

var RNG : RandomNumberGenerator = RandomNumberGenerator.new()

const SFX_BUS = 1
const MUSIC_BUS = 2

# For background music
@onready var music : AudioStreamPlayer = $MusicPlayer;
var music_tween : Tween

# For scene transitions
# Based on https://www.youtube.com/watch?v=yZQStB6nHuI
@onready var ap : AnimationPlayer = $AnimationPlayer
@onready var rect : ColorRect = $DissolveRect

var inventory_goo : int = 10
var inventory_electricity : int = 10

var upgrade_levels : Dictionary = {
	"Player" : 0, 
	"Ballistic" : 0, 
	"Explosive" : 0, 
	"Thermal" : 0}

var tower_stack : Array = []

# Do `await Global.fade` to wait for the animation to finish.
var fade_animation: Signal:
	get: return ap.animation_finished

var color: Color:
	get: return rect.color
	set(value): rect.color = value
	
var _target : String

func _ready():
	RNG.randomize()
	%Settings.visible = false
	%SoundSlider.value_changed.connect(func(value):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
		click()
	)
	%MusicSlider.value_changed.connect(func(value):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
	)
	%ConfigButton.pressed.connect(func():
		settings_visible(!%Settings.visible)
	)
	%CloseButton.pressed.connect(func():
		click()
		settings_visible(false)
	)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(%SoundSlider.value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(%MusicSlider.value))
	%CRT.toggled.connect(func(value):
		$CrtShader.visible = value
	)
	%Fullscreen.toggled.connect(set_fullscreen)

# For button noises
func click():
	$Click.play()

func set_fullscreen(value):
	%Fullscreen.set_pressed_no_signal(value)
	if value:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	

# Trigger audio start on first mouse input for web builds.
func _input(event):
	if event is InputEventMouse:
		if music.stream != null and not music.playing:
			music.play()
	if event.is_action_pressed("ui_cancel") and get_tree().current_scene.name != "LogoAnimation":
		print(get_tree().current_scene.name)
		settings_visible(!%Settings.visible)
	if event.is_action_pressed("ui_fullscreen"):
		set_fullscreen(DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN)

func play_music(stream : AudioStream, volume_db: float = 0.0):
	if music_tween != null:
		music_tween.stop()
		music_tween = null
	music.volume_db = volume_db
	music.stream = stream
	music.play()

func fade_music_out(duration: float, target_db: float = -30.0) -> Signal:
	music_tween = create_tween()
	music_tween.tween_property(music, "volume_db", target_db, duration)
	if target_db <= -30.0:
		music_tween.tween_callback(music.stop)
	return music_tween.finished

func _fade_out(): ap.play("dissolve")
func _fade_in():  ap.play_backwards("dissolve")

# Switch to the given scene. Starts loading the scene in the background while the fade-out plays.
func change_scene_to_file(target: String) -> void:
	# Background load the target scene
	ResourceLoader.load_threaded_request(target, "PackedScene")
	_target = target
	_fade_out()
	await fade_animation
	var status = ResourceLoader.load_threaded_get_status(_target)
	if status != ResourceLoader.THREAD_LOAD_LOADED:
		ap.play("Loading")
	
# Fade out and close the game.
func quit() -> void:
	_fade_out()
	await fade_animation
	get_tree().quit()

func _process(_delta):
	if _target.is_empty(): return
	var status = ResourceLoader.load_threaded_get_status(_target)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		print("Switching to ", _target)
		var scene : PackedScene = ResourceLoader.load_threaded_get(_target)
		_target = ""

		if ap.current_animation == "dissolve" and ap.is_playing():
			await fade_animation

		get_tree().change_scene_to_packed(scene)
		_fade_in.call_deferred()

# Opens the settings screen and pauses the game.
func settings_visible(value):
	%Settings.visible = value
	get_tree().paused = value
