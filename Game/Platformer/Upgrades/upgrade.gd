extends RigidBody2D

@export var value : String = "Grapple"
@export var sprite : AnimatedSprite2D

var has_been_grabbed : bool = false

func _ready() -> void:
	sprite.animation = value



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player and not has_been_grabbed:
		call_deferred("collect", body)

func collect(new_parent):
	reparent(new_parent.item_holder)
	owner = new_parent.item_holder
	has_been_grabbed = true
	freeze = true
	position = Vector2.ZERO
	collision_layer = 0
