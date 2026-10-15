class_name DeathScreen
extends CenterContainer

## DeathScreen
## Sci-fi disintegration death interface for RESPawn: PARALLAX.

signal respawn_requested()

@onready var respawn_btn: Button = $Panel/VBox/RespawnBtn
@onready var reason_label: Label = $Panel/VBox/ReasonLabel

func _ready() -> void:
	UIHelper.style_button(respawn_btn, Color(1.0, 0.25, 0.35))
	respawn_btn.pressed.connect(func(): respawn_requested.emit())

func set_death_reason(reason: String) -> void:
	if reason_label:
		if reason == "abyss_fall":
			reason_label.text = "You plunged into the sub-facility dimensional void."
		elif reason == "laser_burn":
			reason_label.text = "You were vaporized by high-energy thermal laser emissions."
		elif reason == "drone_blast":
			reason_label.text = "You were detected and neutralized by the Security Patrol Drone."
		else:
			reason_label.text = "Lethal structural hazard contact."
