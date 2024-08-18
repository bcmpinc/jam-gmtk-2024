class_name Upgrade_Box extends RigidBody2D

@export_enum("Player", "Ballistic", "Explosive", "Thermal") var station_type : String = "Player"
@export_enum("Small", "Medium", "Large") var rank = 0

@export var sprite : AnimatedSprite2D

var has_been_grabbed : bool = false

var default_parent : Node

func _ready() -> void:
	apply_central_impulse(Vector2(randi_range(100, 150) * 1 if (randf() > 0.5) else -1, -400))
	default_parent = get_parent()
	sprite.animation = station_type
	sprite.frame = rank
	collision_layer = 2
	collision_mask = 2


func _process(delta: float) -> void:
	if has_been_grabbed:
		global_position = get_parent().global_position


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass


func collect(new_parent):
	reparent(new_parent.item_holder)
	has_been_grabbed = true
	freeze = true
	position = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0


func drop(velocity):
	has_been_grabbed = false
	reparent(default_parent)
	freeze = false
	collision_layer = 2
	collision_mask = 2
	linear_velocity = velocity
	

func dispense():
	queue_free()
	
