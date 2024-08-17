extends Node2D

@export_enum("Player", "Ballistic", "Explosive", "Thermal") var station_type : String = "Player"

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
					Global.inventory_electricity -= cur_cost_elec
					Global.inventory_goo -= cur_cost_goo
					Global.upgrade_levels[station_type] += 1
					Global.tower_stack.append({station_type:Global.upgrade_levels[station_type]})
					print("upgrade_levels:\n", Global.upgrade_levels)
					print("\n\ntower_stack:\n", Global.tower_stack)
					bought = true
					anim.play("buy")
