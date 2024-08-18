extends Node2D

@export_enum("Player", "Ballistic", "Explosive", "Thermal") var station_type : String = "Player"


signal interact_currency(what : String, how_much : int)

var upgrade_costs : Dictionary = {
	"Player" :    [{"Electricity" : 1, "Goo" : 1}, {"Electricity" : 2, "Goo" : 2}, {"Electricity" : 3, "Goo" : 3}],
	"Ballistic" : [{"Electricity" : 1, "Goo" : 1}, {"Electricity" : 2, "Goo" : 2}, {"Electricity" : 3, "Goo" : 3}],
	"Explosive" : [{"Electricity" : 1, "Goo" : 1}, {"Electricity" : 2, "Goo" : 2}, {"Electricity" : 3, "Goo" : 3}],
	"Thermal" :   [{"Electricity" : 1, "Goo" : 1}, {"Electricity" : 2, "Goo" : 2}, {"Electricity" : 3, "Goo" : 3}]
	}

@export var sprite : AnimatedSprite2D
@export var label_goo : TweenLabel
@export var label_elec : TweenLabel
@export var area : Area2D
@export var anim : AnimationPlayer

var bought := false

var cur_cost_goo = upgrade_costs[station_type][Global.upgrade_levels[station_type]]["Goo"]
var cur_cost_elec = upgrade_costs[station_type][Global.upgrade_levels[station_type]]["Electricity"]

@onready var upgrade_box : PackedScene = preload("res://Game/Platformer/Upgrades/Upgrade.tscn")

func _ready() -> void:
	sprite.animation = station_type
	label_goo.displayed_value = cur_cost_goo * 100
	label_elec.displayed_value = cur_cost_elec * 100


func _process(delta: float) -> void:
	if not bought and Input.is_action_pressed("accept"):
		var overlapping = area.get_overlapping_bodies()
		for item in overlapping:
			if item is Player:
				if Global.inventory_goo >= cur_cost_goo and Global.inventory_electricity >= cur_cost_elec:
					label_goo.update(0)
					label_elec.update(0)
					interact_currency.emit("Goo", -cur_cost_goo)
					interact_currency.emit("Electricity", -cur_cost_elec)
					
					spit_out_upgrade()
					
					Global.inventory_electricity -= cur_cost_elec
					Global.inventory_goo -= cur_cost_goo
					bought = true
					anim.play("buy")
					$Purchased.play()
				else:
					$UrBroke.play()

func spit_out_upgrade():
	var new_box = upgrade_box.instantiate()
	new_box.station_type = station_type
	new_box.rank = Global.upgrade_levels[station_type]
	new_box.position = position + Vector2(0, -20)
	get_parent().add_child(new_box)
