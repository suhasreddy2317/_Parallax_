class_name UIHelper
extends RefCounted

## UIHelper
## Generates cohesive sci-fi UI styles for RESPawn: PARALLAX.

static func make_panel_style(border_col: Color = Color(0.1, 0.85, 1.0), bg_col: Color = Color(0.06, 0.08, 0.12, 0.94)) -> StyleBoxFlat:
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = bg_col
	sb.border_color = border_col
	sb.border_width_left = 2
	sb.border_width_right = 2
	sb.border_width_top = 2
	sb.border_width_bottom = 2
	sb.corner_radius_top_left = 6
	sb.corner_radius_top_right = 6
	sb.corner_radius_bottom_left = 6
	sb.corner_radius_bottom_right = 6
	sb.content_margin_left = 24
	sb.content_margin_right = 24
	sb.content_margin_top = 16
	sb.content_margin_bottom = 16
	return sb

static func style_button(btn: Button, accent_col: Color = Color(0.1, 0.85, 1.0)) -> void:
	btn.custom_minimum_size = Vector2(220, 44)
	btn.add_theme_font_size_override("font_size", 15)
	
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color(0.10, 0.13, 0.19, 0.9)
	normal.border_color = accent_col.darkened(0.3)
	normal.border_width_left = 1
	normal.border_width_right = 1
	normal.border_width_top = 1
	normal.border_width_bottom = 1
	normal.corner_radius_top_left = 4
	normal.corner_radius_top_right = 4
	normal.corner_radius_bottom_left = 4
	normal.corner_radius_bottom_right = 4
	btn.add_theme_stylebox_override("normal", normal)

	var hover: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.14, 0.20, 0.30, 0.95)
	hover.border_color = accent_col
	hover.border_width_left = 2
	hover.border_width_right = 2
	hover.border_width_top = 2
	hover.border_width_bottom = 2
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("focus", hover)

	var pressed: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	pressed.bg_color = accent_col.darkened(0.6)
	pressed.border_color = Color.WHITE
	btn.add_theme_stylebox_override("pressed", pressed)

	btn.pressed.connect(func():
		if SoundManager.instance:
			SoundManager.instance.play_ui_click()
	)
