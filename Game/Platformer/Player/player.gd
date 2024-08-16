extends CharacterBody2D

enum State {FALL, CLIMB, LATCH, GRAPPLE}

@export var tm : TileMapLayer
var active_grapple : Node = null
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


var state = State.FALL
var dir := Vector2.ZERO

const SPEED = 80.0
const INERTIA = 48.0
const JUMP_VELOCITY = -300.0

var coyote_time := 0.0
var look_time := 0.0

var ladder_behind := false
var taking_damage := false
var on_tm := false

var ladder_tile = Vector2i(1, 1)
var ladder_top = Vector2i(1, 0)

var skip_tiles := []
var next_ground_tile := []

signal hit

@export var camera_center : Node2D
@export var player_sprite : AnimatedSprite2D

@export var ledge_grab : Area2D
@export var space_check : Area2D
@export var floor_check : Area2D

func _process(delta: float) -> void:
	ladder_behind = false
	for i in [-3, 0, 2]:
		if tm.get_cell_atlas_coords(tm.local_to_map(position + Vector2(0, i))) == ladder_tile:
			ladder_behind = true
			break
	if abs(look_time) > 0.8:
		if look_time > 0:
			camera_center.position.y = lerp(camera_center.position.y, -32.0, 0.2)
		if look_time < 0:
			camera_center.position.y = lerp(camera_center.position.y, 32.0, 0.2)
	else:
		camera_center.position.y = lerp(camera_center.position.y, 0.0, 0.2)

func _physics_process(delta: float) -> void:
	dir = Vector2(1,1) if player_sprite.flip_h == false else Vector2(-1, 1)
	if is_on_floor() or state == State.LATCH:
		coyote_time = 0.0
		detatch_from_grapple()
	
	if not ladder_behind and state == State.CLIMB:
		state = State.FALL
	
	
	if not is_on_floor() and state == State.FALL:
		coyote_time += delta
		player_sprite.animation = "jump"
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("accept") and is_on_floor():
		look_time = 0.0
		if state == State.LATCH and Input.is_action_pressed("down"):
			state = State.FALL
		elif is_on_floor() or state in [State.LATCH, State.CLIMB, State.GRAPPLE] or coyote_time < 0.1:
			detatch_from_grapple()
			if coyote_time < 0.1 and not State.GRAPPLE:
				velocity.y = JUMP_VELOCITY
			else:
				velocity.y += JUMP_VELOCITY
		elif len(get_tree().get_nodes_in_group("grapples")) == 0:
			shoot_grapple()
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_released("accept"):
		detatch_from_grapple()
	
	if is_on_floor() and velocity == Vector2.ZERO:
		player_sprite.animation = "idle"
	
	
	var direction := Input.get_axis("left", "right")
	if direction:
		look_time = 0.0
		if not state == State.LATCH:
			player_sprite.flip_h = direction < 0
		if not state in [State.LATCH, State.CLIMB]:
			velocity.x = lerp(velocity.x, direction * SPEED, 0.045)
			ledge_grab.scale.x = dir.x
			space_check.scale.x = dir.x
			floor_check.scale.x = dir.x
			player_sprite.animation = "run"
			if len(skip_tiles) == 0 and len(next_ground_tile) > 0 and is_on_floor() and abs(velocity.x) > 50:
				velocity.y -= 40
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if Input.is_action_pressed("up"):
		if ladder_behind and abs(position.x - tm.map_to_local(tm.local_to_map(position)).x) < 3:
			if tm.get_cell_atlas_coords(tm.local_to_map(position - Vector2(0, 3))) == ladder_tile or \
			   tm.get_cell_atlas_coords(tm.local_to_map(position + Vector2(0, 4))) == ladder_top:
				detatch_from_grapple()
				state = State.CLIMB
				position.x = tm.map_to_local(tm.local_to_map(position)).x
				position.y -= 60.0 * delta
				velocity.y = 0
				player_sprite.animation = "climb"
			
			if is_on_floor():
				position.y -= 1.0
		else:
			look_time += delta
	
	if Input.is_action_pressed("down"):
		look_time -= delta
		var just_on_plank = false
		if tm.get_cell_atlas_coords(tm.local_to_map(position) + Vector2i(0, 1)) == ladder_top and is_on_floor():
			just_on_plank = true
			position.y += 1
			state = State.CLIMB
			ladder_behind = true
		elif state == State.CLIMB and ladder_behind and ((not is_on_floor()) or just_on_plank):
			position.x = tm.map_to_local(tm.local_to_map(position)).x
			position.y += 60.0 * delta
			velocity.y = 0.0
			player_sprite.animation = "climb"
		elif state not in [State.LATCH, State.GRAPPLE]:
			state = State.FALL
	
	if Input.is_action_just_released("down") and state == State.LATCH:
		player_sprite.animation = "latch"
	
	if Input.is_action_just_released("up") or Input.is_action_just_released("down"):
		look_time = 0.0
	
	move_and_slide()


func detatch_from_grapple():
	pass

func shoot_grapple():
	pass
