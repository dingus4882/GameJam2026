extends Node

var container = self
func play_beach():
	container.get_node("Beach").play()
func play_forest():
	container.get_node("Forest").play()
func play_main_menu():
	container.get_node("Main_menu").play()
func play_sewers():
	container.get_node("Sewers").play()
func play_village():
	container.get_node("Village").play()
