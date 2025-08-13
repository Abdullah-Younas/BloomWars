# Label.gd
extends Label

var click_count: int = 0
var current_texture: Texture2D = null
var bg_color: Color = Color(0.137, 0.239, 0.118) # white background

func _ready() -> void:
	_apply_style(bg_color)
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	custom_minimum_size = Vector2(150, 150) # Match your texture size

func set_texture(texture: Texture2D) -> void:
	current_texture = texture
	_update_texture_style()

func get_texture() -> Texture2D:
	return current_texture

func set_color(new_color: Color) -> void:
	bg_color = new_color
	_apply_style(bg_color)

func get_color() -> Color:
	return bg_color

func _apply_style(c: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = c
	style.set_corner_radius_all(10)
	add_theme_stylebox_override("normal", style)

func _update_texture_style() -> void:
	if current_texture:
		var texture_style = StyleBoxTexture.new()
		texture_style.texture = current_texture
		texture_style.texture_margin_left = 0
		texture_style.texture_margin_right = 0
		texture_style.texture_margin_top = 0
		texture_style.texture_margin_bottom = 0
		add_theme_stylebox_override("normal", texture_style)
	else:
		_apply_style(bg_color)
