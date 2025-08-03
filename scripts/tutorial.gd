class_name Tutorial
extends Control

var curr_tutorial_index := 0

@onready var tutorial_cards = [
	$Tutorial_Intro,
	$Tutorial_Connections,
	$Tutorial_Systems_Overview,
	$Tutorial_Asteroids,
	$Tutorial_Enemy_Ships,
	$Tutorial_Health,
	$Tutorial_Repairs,
	$Tutorial_Black_Hole,
	$Tutorial_HighScore
]

func _ready() -> void:
	for c in tutorial_cards:
		var card = c as TutorialCard
		card.hide()
		card.on_next.connect(on_next)
		card.on_back.connect(on_back)
	tutorial_cards[0].show()

func on_next():
	if curr_tutorial_index == tutorial_cards.size() - 1:
		get_tree().change_scene_to_file("res://scenes/start.tscn")
	else:
		tutorial_cards[curr_tutorial_index].hide()
		curr_tutorial_index = min(curr_tutorial_index + 1, tutorial_cards.size() - 1)
		tutorial_cards[curr_tutorial_index].show()

func on_back():
	tutorial_cards[curr_tutorial_index].hide()
	curr_tutorial_index = max(curr_tutorial_index - 1, 0)
	tutorial_cards[curr_tutorial_index].show()	
