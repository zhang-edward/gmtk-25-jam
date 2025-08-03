extends RichTextLabel

@onready var top_screen: TopScreen = get_parent()

func _process(_delta):
	text = str(round(top_screen.black_hole_distance))