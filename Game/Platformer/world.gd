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
	


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Upgrade_Box:
		Global.upgrade_levels[body.station_type] += 1
		Global.tower_stack.append({body.station_type:Global.upgrade_levels[body.station_type]})
		print(Global.tower_stack)
		body.collision_layer = 0
		body.collision_mask = 0
		body.linear_velocity = Vector2.ZERO
		body.apply_central_impulse(Vector2(0, -100))
		await get_tree().create_timer(0.4).timeout
		$Gulp.play()
		await get_tree().create_timer(0.3).timeout
		$GPUParticles2D.emitting = true
