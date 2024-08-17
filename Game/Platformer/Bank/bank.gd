extends Node2D

@export_enum("Goo", "Electricity") var bank_type : String


signal pay_player(what : String, how_much : int)

var has_been_used := false

var coffers := 10

@export var sprite : AnimatedSprite2D
@export var area : Area2D
@export var anim : AnimationPlayer
@export var label : TweenLabel

func _ready() -> void:
	label.displayed_value = coffers * 100
	sprite.animation = bank_type
	match bank_type:
		"Goo":
			label.add_theme_color_override("default_color", Color(0xD3E549))
		"Electricity":
			label.add_theme_color_override("default_color", Color(0xFBC531))


func _process(delta: float) -> void:
	if not has_been_used and Input.is_action_pressed("accept"):
		var overlapping = area.get_overlapping_bodies()
		for item in overlapping:
			if item is Player:
				pay_player.emit(bank_type, coffers)
				label.update(0)
				has_been_used = true
