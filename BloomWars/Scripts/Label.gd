# Label.gd
extends Label

var click_count: int = 0
var bg_color: Color = Color(1,1,1,1) # white

func _ready() -> void:
	# ensure initial style matches bg_color
	_apply_style(bg_color)

func set_color(new_color: Color) -> void:
	bg_color = new_color
	_apply_style(bg_color)

func get_color() -> Color:
	return bg_color

func _apply_style(c: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = c
	add_theme_stylebox_override("normal", style)
