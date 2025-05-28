extends PopupPanel

# resizing panel to text for popup
func resize_to_text():
	var label = $MarginContainer/Label
	# get font for sizing purposes
	var font = label.get_theme_font("font")
	if font == null:
		return
	
	var max_width = max_size.x
	var padding = 40

	# find the wrapped text size
	var text_size = font.get_multiline_string_size(label.text, max_width)

	 # calculate width and height with padding, clamped to limits
	var width = clamp(text_size.x + padding, min_size.x, max_width)
	var height = clamp(text_size.y + padding, min_size.y, max_size.y)

	# update label min size to control wrapping
	label.custom_minimum_size = Vector2(width - padding, 0)
	
	# set popup size
	size = Vector2(width, height)
