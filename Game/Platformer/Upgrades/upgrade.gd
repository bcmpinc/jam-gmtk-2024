extends RigidBody2D

@export var value : String = "Grapple"
@export var sprite : AnimatedSprite2D

var has_been_grabbed : bool = false

var default_parent : Node

func _ready() -> void:
	default_parent = get_parent()
	sprite.animation = value


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player and not has_been_grabbed:
		call_deferred("collect", body)


func collect(new_parent):
	reparent(new_parent.item_holder)
	has_been_grabbed = true
	freeze = true
	position = Vector2.ZERO
	collision_layer = 0

func drop():
	var last_vel = get_parent().get_parent().linear_velocity 
	reparent(default_parent)
	has_been_grabbed = false
	freeze = false
	collision_layer = 2
	collision_mask = 2
	linear_velocity = last_vel
	

func dispense():
	queue_free()
	
