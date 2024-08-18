extends Node

@export var cam : Camera2D
@export var player : CharacterBody2D

@export var bg_muisc : AudioStream

func _ready() -> void:
	update_wallet()
	Global.play_music(bg_muisc)
	cam.position = player.position
	
	for kiosk in get_tree().get_nodes_in_group("kiosk"):
		kiosk.interact_currency.connect(update_wallet)

func _process(delta: float) -> void:
	cam.position = lerp(cam.position, player.camera_center.global_position, 18*delta)

func update_wallet(currency_type : String = '', amount : int = 0):
	# positive is added to the balance, negative is subtracted
	match currency_type:
		"Goo":
			Global.inventory_goo += amount
		"Electricity":
			Global.inventory_electricity += amount
		'':
			pass
	$CanvasLayer/HUD/GooInventory.update(Global.inventory_goo * 100)
	$CanvasLayer/HUD/ElecInventory.update(Global.inventory_electricity * 100)
	
