class_name MainMenu
extends Control

## MainMenu
## Atmospheric sci-fi title interface for RESPawn: PARALLAX.

signal start_campaign_requested()
signal stage_selected(stage_id: int)
signal settings_requested()
signal local_multiplayer_requested()

@onready var single_player_btn: Button = $Center/MainVBox/MenuButtons/SinglePlayerBtn
@onready var stage_select_btn: Button = $Center/MainVBox/MenuButtons/StageSelectBtn
@onready var settings_btn: Button = $Center/MainVBox/MenuButtons/SettingsBtn
@onready var credits_btn: Button = $Center/MainVBox/MenuButtons/CreditsBtn
@onready var local_multiplayer_btn: Button = $Center/MainVBox/MenuButtons/LocalMultiplayerBtn
@onready var quit_btn: Button = $Center/MainVBox/MenuButtons/QuitBtn

# Sub panels
@onready var stage_select_panel: CenterContainer = $StageSelectModal
@onready var credits_panel: CenterContainer = $CreditsModal

@onready var stage1_btn: Button = $StageSelectModal/Panel/VBox/Stage1Btn
@onready var stage2_btn: Button = $StageSelectModal/Panel/VBox/Stage2Btn
@onready var stage3_btn: Button = $StageSelectModal/Panel/VBox/Stage3Btn
@onready var stage_close_btn: Button = $StageSelectModal/Panel/VBox/CloseStageBtn
@onready var credits_close_btn: Button = $CreditsModal/Panel/VBox/CloseCreditsBtn

func _ready() -> void:
	UIHelper.style_button(single_player_btn, Color(0.1, 0.85, 1.0))
	UIHelper.style_button(local_multiplayer_btn, Color(0.95, 0.2, 0.75))
	UIHelper.style_button(stage_select_btn, Color(0.1, 0.85, 1.0))
	UIHelper.style_button(settings_btn, Color(0.1, 0.85, 1.0))
	UIHelper.style_button(credits_btn, Color(0.1, 0.85, 1.0))
	UIHelper.style_button(quit_btn, Color(0.9, 0.3, 0.4))

	UIHelper.style_button(stage1_btn, Color(0.1, 0.85, 1.0))
	UIHelper.style_button(stage2_btn, Color(0.95, 0.2, 0.75))
	UIHelper.style_button(stage3_btn, Color(0.2, 0.95, 0.65))
	UIHelper.style_button(stage_close_btn, Color(0.6, 0.7, 0.85))
	UIHelper.style_button(credits_close_btn, Color(0.1, 0.85, 1.0))

	single_player_btn.pressed.connect(func(): start_campaign_requested.emit())
	local_multiplayer_btn.pressed.connect(func(): local_multiplayer_requested.emit())
	stage_select_btn.pressed.connect(func(): stage_select_panel.visible = true)
	settings_btn.pressed.connect(func(): settings_requested.emit())
	credits_btn.pressed.connect(func(): credits_panel.visible = true)
	quit_btn.pressed.connect(func(): get_tree().quit())

	stage1_btn.pressed.connect(func():
		stage_select_panel.visible = false
		stage_selected.emit(1)
	)
	stage2_btn.pressed.connect(func():
		stage_select_panel.visible = false
		stage_selected.emit(2)
	)
	stage3_btn.pressed.connect(func():
		stage_select_panel.visible = false
		stage_selected.emit(3)
	)
	stage_close_btn.pressed.connect(func(): stage_select_panel.visible = false)
	credits_close_btn.pressed.connect(func(): credits_panel.visible = false)



