class_name PauseMenu
extends CenterContainer

## PauseMenu
## In-game pause modal for RESPawn: PARALLAX.

signal resume_requested()
signal restart_requested()
signal settings_requested()
signal main_menu_requested()

@onready var resume_btn: Button = $Panel/VBox/ResumeBtn
@onready var restart_btn: Button = $Panel/VBox/RestartBtn
@onready var settings_btn: Button = $Panel/VBox/SettingsBtn
@onready var menu_btn: Button = $Panel/VBox/MenuBtn

func _ready() -> void:
	UIHelper.style_button(resume_btn, Color(0.1, 0.85, 1.0))
	UIHelper.style_button(restart_btn, Color(0.1, 0.85, 1.0))
	UIHelper.style_button(settings_btn, Color(0.1, 0.85, 1.0))
	UIHelper.style_button(menu_btn, Color(0.9, 0.3, 0.4))
	
	resume_btn.pressed.connect(func(): resume_requested.emit())
	restart_btn.pressed.connect(func(): restart_requested.emit())
	settings_btn.pressed.connect(func(): settings_requested.emit())
	menu_btn.pressed.connect(func(): main_menu_requested.emit())
