extends Node

var current_level_name: String

#im gonna handicap this turtle
@export var source_of_disability:Array[String] = []

var selected_inventory_slot:Node

var mutation_name_of_flower:Dictionary[String, String] \
= {
"Poison_lily" : "vomit",
}
var flower_obtained:Array[String] = []
