class_name TweenLabel extends RichTextLabel

@export var prefix : String
@export var suffix : String

@export_range(0.0, 2.0, 0.05) var anim_length : float = 1.0

signal finished_tweening

var displayed_value : int :
	get:
		return displayed_value
	set(value):
		displayed_value = value
		text = "%s%s%s" % [prefix, str(displayed_value), suffix]

var sum_value : int

func update(new_value : int, color_change : bool = false):
	sum_value = new_value
	var tween : Tween = create_tween()
	if color_change:
		if sum_value > displayed_value:
			tween.tween_property(self, "self_modulate", Color.WHITE, 0.2).from(Color.GREEN)
		elif sum_value < displayed_value:
			tween.tween_property(self, "self_modulate", Color.WHITE, 0.2).from(Color.RED)
	tween.tween_property(self, "displayed_value", sum_value, anim_length)
	tween.finished.connect(emit_signal.bind("finished_tweening"))
