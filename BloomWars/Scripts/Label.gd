extends Label

var clicked := false
var player1 := false

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and !clicked:
		if player1:
			var style = StyleBoxFlat.new()
			style.bg_color = Color.RED
			add_theme_stylebox_override("normal", style)
			player1 = false
			clicked = true
		elif !player1:
			var style = StyleBoxFlat.new()
			style.bg_color = Color.BLUE
			add_theme_stylebox_override("normal", style)
			player1 = true
			clicked = true
			
