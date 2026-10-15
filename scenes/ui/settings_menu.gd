class_name SettingsMenu
extends CenterContainer

## SettingsMenu
## Configuration interface for audio, display mode, and controls reference.

signal closed()

@onready var master_slider: HSlider = $Panel/VBox/MasterRow/MasterSlider
@onready var sfx_slider: HSlider = $Panel/VBox/SfxRow/SfxSlider
@onready var fullscreen_check: CheckBox = $Panel/VBox/DisplayRow/FullscreenCheck
@onready var back_btn: Button = $Panel/VBox/BackBtn

func _ready() -> void:
	UIHelper.style_button(back_btn, Color(0.1, 0.85, 1.0))
	back_btn.pressed.connect(func(): closed.emit())

	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	master_slider.value_changed.connect(_on_master_changed)

	sfx_slider.value = 0.8
	sfx_slider.value_changed.connect(_on_sfx_changed)

	var is_fullscreen: bool = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	fullscreen_check.button_pressed = is_fullscreen
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)

func _on_master_changed(val: float) -> void:
	if SoundManager.instance:
		SoundManager.instance.set_master_volume(val)

func _on_sfx_changed(val: float) -> void:
	if SoundManager.instance:
		SoundManager.instance.set_sfx_volume(val)
		SoundManager.instance.play_ui_click()

func _on_fullscreen_toggled(is_fs: bool) -> void:
	if is_fs:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
