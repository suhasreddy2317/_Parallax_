class_name Stage1FirstContact
extends StageBase

## Stage 1 — FIRST CONTACT
## Introductory stage: teaches movement, jumping, reality switching [Q], and door opening.

func _init() -> void:
	stage_index = 1
	stage_title = "STAGE 01: FIRST CONTACT"
	stage_objective = "• Objective: Phase shift [Q] across chasms, open security door with [E], reach transit gate."
	default_spawn_position = Vector2(100.0, 480.0)

func _ready() -> void:
	super._ready()
	_build_level()

func configure_cooperative_reality(reality: int) -> void:
	super.configure_cooperative_reality(reality)
	var switch_s1 := get_node("SwitchS1") as PuzzleSwitch
	var door_s1 := get_node("DoorS1") as PuzzleDoor
	door_s1.set_door_size(Vector2(28.0, 500.0))

	if reality == RealityManager.Reality.REALITY_A:
		switch_s1.set_cooperative_latched(true)
		var bridge := ShiftableObject.new()
		bridge.name = "CrossRealityBridgeA"
		bridge.position = Vector2(690.0, 440.0)
		bridge.object_size = Vector2(140.0, 22.0)
		bridge.active_reality = RealityManager.Reality.REALITY_A
		add_child(bridge)
		bridge.set_reality_override(reality)
		bridge.set_linked_active(false)

		var final_step := ShiftableObject.new()
		final_step.name = "AOnlyFinalStep"
		final_step.position = Vector2(1610.0, 350.0)
		final_step.object_size = Vector2(120.0, 22.0)
		final_step.active_reality = RealityManager.Reality.REALITY_A
		add_child(final_step)
		final_step.set_reality_override(reality)
	else:
		switch_s1.set_switch_enabled(false)
		var relay_switch := PuzzleSwitch.new()
		relay_switch.name = "BRelaySwitch"
		relay_switch.position = Vector2(270.0, 480.0)
		relay_switch.is_toggle_type = true
		relay_switch.set_cooperative_latched(true)
		add_child(relay_switch)

		var relay_step := ShiftableObject.new()
		relay_step.name = "BRelayStep"
		relay_step.position = Vector2(790.0, 440.0)
		relay_step.object_size = Vector2(150.0, 22.0)
		relay_step.active_reality = RealityManager.Reality.REALITY_B
		add_child(relay_step)
		relay_step.set_reality_override(reality)

		var final_relay := ShiftableObject.new()
		final_relay.name = "BFinalStep"
		final_relay.position = Vector2(1490.0, 420.0)
		final_relay.object_size = Vector2(140.0, 22.0)
		final_relay.active_reality = RealityManager.Reality.REALITY_B
		add_child(final_relay)
		final_relay.set_reality_override(reality)
		var plat_b1 := get_node("Plat_B1") as ShiftableObject
		plat_b1.position = Vector2(580.0, 460.0)
		var plat_b2 := get_node("Plat_B2") as ShiftableObject
		plat_b2.position = Vector2(1640.0, 360.0)

func _build_level() -> void:
	# 1. Starting platform and boundary
	create_static_block(Vector2(200, 540), Vector2(400, 48))
	create_static_block(Vector2(0, 270), Vector2(24, 600)) # Left boundary wall

	# Hint billboard / visual text for tutorial
	_add_signpost(Vector2(140, 460), "[A / D] Move   |   [SPACE] Jump")
	_add_signpost(Vector2(360, 460), "CHASM AHEAD: Press [Q] to shift realities")

	# 2. Dimensional Chasm Platforms
	# Reality A Platform (Cyan)
	var plat_a: ShiftableObject = ShiftableObject.new()
	plat_a.name = "Plat_A1"
	plat_a.position = Vector2(500, 460)
	plat_a.object_size = Vector2(120, 22)
	plat_a.active_reality = RealityManager.Reality.REALITY_A
	add_child(plat_a)

	# Reality B Platform (Magenta)
	var plat_b: ShiftableObject = ShiftableObject.new()
	plat_b.name = "Plat_B1"
	plat_b.position = Vector2(720, 400)
	plat_b.object_size = Vector2(120, 22)
	plat_b.active_reality = RealityManager.Reality.REALITY_B
	add_child(plat_b)

	# 3. Mid Landing Area
	create_static_block(Vector2(1040, 480), Vector2(360, 40))

	# Switch & Door Puzzle
	var switch_s1: PuzzleSwitch = PuzzleSwitch.new()
	switch_s1.name = "SwitchS1"
	switch_s1.position = Vector2(960, 450)
	switch_s1.is_toggle_type = true
	add_child(switch_s1)
	_add_signpost(Vector2(960, 410), "Press [E] or step on terminal to unlock")

	var door_s1: PuzzleDoor = PuzzleDoor.new()
	door_s1.name = "DoorS1"
	door_s1.position = Vector2(1180, 430)
	door_s1.door_size = Vector2(24, 110)
	add_child(door_s1)

	switch_s1.toggled.connect(door_s1.set_powered)

	# 4. Checkpoint before the final leap
	var cp: CheckpointTerminal = CheckpointTerminal.new()
	cp.name = "CheckpointS1"
	cp.position = Vector2(1300, 440)
	cp.checkpoint_id = 1
	add_child(cp)

	# 5. Final Obstacle: High Elevation Phase Bridge
	create_static_block(Vector2(1300, 480), Vector2(180, 40))

	var plat_a2: ShiftableObject = ShiftableObject.new()
	plat_a2.name = "Plat_A2"
	plat_a2.position = Vector2(1470, 410)
	plat_a2.object_size = Vector2(110, 22)
	plat_a2.active_reality = RealityManager.Reality.REALITY_A
	add_child(plat_a2)

	var plat_b2: ShiftableObject = ShiftableObject.new()
	plat_b2.name = "Plat_B2"
	plat_b2.position = Vector2(1640, 360)
	plat_b2.object_size = Vector2(110, 22)
	plat_b2.active_reality = RealityManager.Reality.REALITY_B
	add_child(plat_b2)

	# Exit Ledge & Transit Gate
	create_static_block(Vector2(1860, 360), Vector2(220, 36))
	create_static_block(Vector2(1980, 180), Vector2(24, 400)) # Right boundary

	var exit: ExitPortal = ExitPortal.new()
	exit.name = "ExitPortalS1"
	exit.position = Vector2(1880, 310)
	exit.next_stage_id = 2
	exit.portal_label = "STAGE 02"
	add_child(exit)

	# Re-connect checkpoint and exit triggers
	_connect_checkpoints_and_exits()

func _add_signpost(pos: Vector2, text: String) -> void:
	var lbl: Label = Label.new()
	lbl.text = text
	lbl.position = pos - Vector2(140, 20)
	lbl.custom_minimum_size = Vector2(280, 30)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color(0.5, 0.7, 0.9, 0.8))
	add_child(lbl)
