extends RichTextLabel

@onready var top_screen: TopScreen = get_parent()

func _process(_delta):
	var distance = top_screen.black_hole_distance
	
	# Hide label when black hole is far away
	if distance > 1000:
		visible = false
		return
	else:
		visible = true
	
	
	# Calculate red color intensity (closer = more red)
	var red_intensity = 1.0 - (distance / 1000.0) # 0.0 to 1.0
	var green_blue = max(0.0, 1.0 - red_intensity * 1.5) # Fade out green/blue faster
	var color_hex = Color(1.0, green_blue, green_blue).to_html()
	
	text = "[color=#%s]POWER ON ENGINES! Event horizon in %s[/color]" % [color_hex, str(round(distance) / 100)]