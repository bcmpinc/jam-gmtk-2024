extends Node2D

@export_enum("Player", "Ballistic", "Explosive", "Thermal") var station_type : String = "Player"

var upgrade_costs : Dictionary = {
	"Player" :    [{"Electricity" : 1, "Goo" : 1}, {"Electricity" : 2, "Goo" : 2}, {"Electricity" : 3, "Goo" : 3}],
	"Ballistic" : [{"Electricity" : 1, "Goo" : 1}, {"Electricity" : 2, "Goo" : 2}, {"Electricity" : 3, "Goo" : 3}],
	"Explosive" : [{"Electricity" : 1, "Goo" : 1}, {"Electricity" : 2, "Goo" : 2}, {"Electricity" : 3, "Goo" : 3}],
	"Thermal" :   [{"Electricity" : 1, "Goo" : 1}, {"Electricity" : 2, "Goo" : 2}, {"Electricity" : 3, "Goo" : 3}]
	}

@export var sprite : AnimatedSprite2D

func _ready() -> void:
	sprite.animation = station_type



func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		print('player is here')
