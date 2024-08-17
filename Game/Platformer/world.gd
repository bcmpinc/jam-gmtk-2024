extends Node

@export var cam : Camera2D
@export var player : CharacterBody2D

@export var bg_muisc : AudioStream

func _ready() -> void:
	Global.play_music(bg_muisc)
	cam.position = player.position
	
	for bank in get_tree().get_nodes_in_group("bank"):
		bank.pay_player.connect(add_to_wallet)

func _process(delta: float) -> void:
	cam.position = lerp(cam.position, player.camera_center.global_position, 18*delta)

func add_to_wallet(currency_type : String, amount : int):
	match currency_type:
		"Goo":
			Global.inventory_goo += amount
		"Electricity":
			Global.inventory_electricity += amount
