class_name Player extends CharacterBody2D

enum State {FALL, LATCH, GRAPPLE, ASCEND}
enum Abilities {GRAPPLE, DOUBLE_JUMP, DASH, JETPACK}

@onready var grapple : PackedScene = preload("res://Game/Platformer/Player/HookGrapple.tscn")

@export var tm : TileMapLayer

var active_grapple : Node = null
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var state = State.FALL

const SPEED = 180.0
const INERTIA = 48.0
const JUMP_VELOCITY = -280.0

var coyote_time := 0.0
var look_time := 0.0
var jetpack_juice := 2.0
var dash_cooldown := 0.25
var double_tap_last_seen := 0.0
var last_tapped_direction := 0.0

var ladder_behind := false

var ladder_tile = Vector2i(1, 1)
var ladder_top = Vector2i(1, 0)

var skip_tiles := []
var next_ground_tile := []
var detector_list := []

var dir := Vector2.ZERO

var holding_an_item := false:
	get:
		return len(item_holder.get_children()) > 0

var unlocked_abilities : Array[int] = [Abilities.JETPACK, Abilities.GRAPPLE]

@export var camera_center : Node2D
@export var player_sprite : AnimatedSprite2D

@export var ledge_grab : Area2D
@export var space_check : Area2D
@export var floor_check : Area2D

@export var item_holder : Node2D

@export var jetpack_sound : AudioStreamPlayer
@export var jetpack_particles : GPUParticles2D


func _ready() -> void:
	jetpack_particles.amount_ratio = 0.0


func _physics_process(delta: float) -> void:
	var was_in_air := not is_on_floor()
	var last_velocity = velocity.y
	if abs(look_time) > 0.8:
		if look_time > 0:
			camera_center.position.y = lerp(camera_center.position.y, -128.0, 0.2)
		if look_time < 0:
			camera_center.position.y = lerp(camera_center.position.y, 128.0, 0.2)
	else:
		camera_center.position.y = lerp(camera_center.position.y, 0.0, 0.2)
	dir = Vector2(1, 1) if player_sprite.flip_h == false else Vector2(-1, 1)
	double_tap_last_seen -= delta
	if is_on_floor() or state == State.LATCH:
		jetpack_juice = 2.0
		coyote_time = 0.0
		detatch_from_grapple()

	if not is_on_floor() and state == State.FALL:
		coyote_time += delta
		player_sprite.animation = "jump"
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("accept"):
		look_time = 0.0
		if state == State.LATCH and Input.is_action_pressed("down"):
			state = State.FALL
		elif is_on_floor() or state in [State.LATCH, State.GRAPPLE] or coyote_time < 0.1:
			detatch_from_grapple()
			if coyote_time < 0.1 and not State.GRAPPLE:
				velocity.y = JUMP_VELOCITY
			else:
				velocity.y += JUMP_VELOCITY
			$JumpSound.play()
		elif len(get_tree().get_nodes_in_group("grapples")) == 0 and Abilities.GRAPPLE in unlocked_abilities:
			shoot_grapple()
	
	if Input.is_action_just_released("accept"):
		detatch_from_grapple()
	
	if is_on_floor() and velocity == Vector2.ZERO:
		player_sprite.animation = "idle"
	
	var direction := Input.get_axis("left", "right")
	if direction:
		item_holder.position.x = -7 if direction > 0 else 7
		jetpack_particles.position.x = -5 if direction > 0 else 5
		jetpack_particles.scale.x = direction
		look_time = 0.0
		if not state == State.LATCH:
			player_sprite.flip_h = direction < 0
			velocity.x = lerp(velocity.x, direction * SPEED, 0.045)
			ledge_grab.scale.x = direction
			space_check.scale.x = direction
			floor_check.scale.x = direction
			player_sprite.animation = "run"
			if len(skip_tiles) == 0 and len(next_ground_tile) > 0 and is_on_floor() and abs(velocity.x) > 50:
				velocity.y -= 100
	else:
		velocity.x = lerp(velocity.x, 0.0, delta * 10)
	
	var last_pressed_dir = null
	for i in ["left", "right"]:
		if Input.is_action_just_released(i):
			last_pressed_dir = [-1, 1][["left", "right"].find(i)]
	if last_pressed_dir:
		if double_tap_last_seen >= 0.0 and last_tapped_direction == last_pressed_dir:
			for i in range(6, 0, -1):
				var cur_spot = tm.get_cell_atlas_coords(tm.local_to_map(position) + Vector2i(i*last_pressed_dir, 0))
				if cur_spot == Vector2i(-1, -1):
					position = tm.map_to_local(tm.local_to_map(position) + Vector2i(i*last_pressed_dir, 0))
					double_tap_last_seen = 0.0
					last_tapped_direction = 0.0
					break
		else:
			double_tap_last_seen = dash_cooldown
			last_tapped_direction = last_pressed_dir

	if Input.is_action_pressed("up"):
		if jetpack_juice > 0 and not is_on_floor() and len(get_tree().get_nodes_in_group("grapples")) == 0 and Abilities.JETPACK in unlocked_abilities:
			position.y -= 60.0 * delta
			velocity.y *= 0.1
			jetpack_juice -= delta
			if not jetpack_sound.playing:
				jetpack_particles.amount_ratio = 1.0
				jetpack_sound.play()
		else:
			look_time += delta

	
	if Input.is_action_pressed("drop") and holding_an_item:
		item_holder.get_child(0).drop()
	
	if Input.is_action_pressed("down"):
		look_time -= delta
		var just_on_plank = false
		if Input.is_action_pressed("accept") and holding_an_item:
			item_holder.get_child(0).drop()
		elif state not in [State.LATCH, State.GRAPPLE]:
			state = State.FALL
			
	
	if Input.is_action_just_released("down") and state == State.LATCH:
		player_sprite.animation = "latch"
	
	if Input.is_action_just_released("up") or Input.is_action_just_released("down"):
		if jetpack_sound.playing:
			jetpack_particles.amount_ratio = 0.0
			jetpack_sound.stop()
		look_time = 0.0
	
	move_and_slide()
	
	if is_on_floor():
		if was_in_air and last_velocity > 100:
			$LandSound.play()
	

func detatch_from_grapple():
	if active_grapple != null:
		if active_grapple.state == active_grapple.State.LATCH:
			velocity = active_grapple.player_holder.linear_velocity
		state = State.FALL
		active_grapple.change_state(active_grapple.State.RETRACT)
		active_grapple = null


func shoot_grapple():
	var cur_grap = grapple.instantiate()
	cur_grap.target = self
	active_grapple = cur_grap
	get_parent().add_child(cur_grap)
	


func try_latch():
	if ledge_grab.has_overlapping_bodies() and not is_on_floor() and not space_check.has_overlapping_bodies():
		detatch_from_grapple()
		state = State.LATCH
		velocity = Vector2.ZERO
		position.y = snapped(position.y - 8, 16) + 8
		position.x = tm.map_to_local(tm.local_to_map(position)).x
		player_sprite.animation = "latch"



func _on_ledge_clip_detector_body_exited(_body: Node2D) -> void:
	try_latch()


func _on_interact_area_body_entered(body: Node2D) -> void:
	if not body == tm:
		pass


func _on_floor_detector_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, local_shape_index: int) -> void:
	if local_shape_index == 0:
		next_ground_tile.append(body)
	if local_shape_index > 0:
		skip_tiles.append(body)


func _on_floor_detector_body_shape_exited(_body_rid: RID, body: Node2D, _body_shape_index: int, local_shape_index: int) -> void:
	if local_shape_index == 0 and body in next_ground_tile:
		next_ground_tile.erase(body)
	if local_shape_index > 0 and body in skip_tiles:
		skip_tiles.erase(body)


func _on_ledge_grab_area_body_entered(body: Node2D) -> void:
	if body == tm:
		try_latch()


func _on_ledge_grab_area_body_exited(_body: Node2D) -> void:
	if state == State.LATCH:
		state = State.FALL


func _on_interact_area_area_entered(area: Area2D) -> void:
	if not area == tm:
		pass
