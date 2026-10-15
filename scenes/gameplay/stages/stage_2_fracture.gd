class_name Stage2Fracture
extends StageBase

## Stage 2 — FRACTURE
## Introduces optical puzzle mechanics: geometric laser reflection, rotatable mirrors,
## receivers, blast doors, and lethal hazard beams.

func _init() -> void:
	stage_index = 2
	stage_title = "STAGE 02: FRACTURE"
	stage_objective = "• Objective: Phase out dimensional barrier [Q], rotate mirror [E] to reflect beam into overhead receiver."
	default_spawn_position = Vector2(100.0, 460.0)

func _ready() -> void:
	super._ready()
	_build_level()

func configure_cooperative_reality(reality: int) -> void:
	super.configure_cooperative_reality(reality)
	var door := get_node("BlastDoorS2") as PuzzleDoor
	door.set_door_size(Vector2(28.0, 450.0))
	if reality == RealityManager.Reality.REALITY_B:
		var mover := get_node("Mover_S2") as MovingPlatform
		mover.travel_offset = Vector2(180.0, -48.0)
		var mirror := get_node("PuzzleMirror") as LaserMirror
		mirror.position.x = 1320.0
		var receiver := get_node("OverheadReceiver") as LaserReceiver
		receiver.position.x = 1320.0
		var local_door := door
		var local_receiver := receiver
		if local_receiver.powered_changed.is_connected(local_door.set_powered):
			local_receiver.powered_changed.disconnect(local_door.set_powered)

		var relay_switch := PuzzleSwitch.new()
		relay_switch.name = "BRelaySwitchS2"
		relay_switch.position = Vector2(230.0, 460.0)
		relay_switch.is_toggle_type = true
		relay_switch.set_cooperative_latched(true)
		add_child(relay_switch)

		var relay_step := ShiftableObject.new()
		relay_step.name = "BPhaseStepS2"
		relay_step.position = Vector2(620.0, 450.0)
		relay_step.object_size = Vector2(120.0, 22.0)
		relay_step.active_reality = RealityManager.Reality.REALITY_B
		add_child(relay_step)
		relay_step.set_reality_override(reality)

func _build_level() -> void:
	# 1. Starting platform and boundary
	create_static_block(Vector2(160, 520), Vector2(320, 40))
	create_static_block(Vector2(0, 260), Vector2(24, 600)) # Left boundary wall

	# 2. Moving Platform across first hazard gap
	var mover: MovingPlatform = MovingPlatform.new()
	mover.name = "Mover_S2"
	mover.position = Vector2(440, 470)
	mover.travel_offset = Vector2(140, 0)
	mover.travel_duration = 3.0
	add_child(mover)

	# 3. Intermediate staging platform with Checkpoint 1
	create_static_block(Vector2(740, 490), Vector2(240, 36))
	var cp1: CheckpointTerminal = CheckpointTerminal.new()
	cp1.name = "CheckpointS2_1"
	cp1.position = Vector2(740, 440)
	cp1.checkpoint_id = 1
	add_child(cp1)

	# 4. OPTICAL PUZZLE CHAMBER (X: 860 to 1600)
	# Floor of the puzzle room
	create_static_block(Vector2(1200, 520), Vector2(680, 40))
	# Ceiling
	create_static_block(Vector2(1200, 40), Vector2(680, 24))

	# Optical Laser Emitter (Safe puzzle beam)
	var emitter: LaserEmitter = LaserEmitter.new()
	emitter.name = "OpticalEmitter"
	emitter.position = Vector2(920, 340)
	emitter.laser_direction = Vector2.RIGHT
	emitter.burn_player_on_touch = false
	emitter.beam_color = Color(0.15, 0.85, 1.0)
	emitter.max_range = 1400.0
	emitter.mode = LaserEmitter.LaserMode.STATIC
	add_child(emitter)

	# Reality A Barrier (Blocks beam in Reality A; player must shift to Reality B to allow beam to pass)
	var barrier: ShiftableObject = ShiftableObject.new()
	barrier.name = "LaserBarrier_A"
	barrier.position = Vector2(1080, 340)
	barrier.object_size = Vector2(34, 130)
	barrier.active_reality = RealityManager.Reality.REALITY_A
	add_child(barrier)

	_add_signpost(Vector2(1080, 240), "Barrier blocks beam in Reality A. Shift [Q] to phase it out.")

	# Rotatable Prismatic Mirror
	var mirror: LaserMirror = LaserMirror.new()
	mirror.name = "PuzzleMirror"
	mirror.position = Vector2(1260, 340)
	mirror.mirror_angle_degrees = 90.0 # Vertical, needs rotation to 135 deg to reflect UP!
	add_child(mirror)

	_add_signpost(Vector2(1260, 410), "Press [E] to rotate mirror to 45° angle.")

	# Overhead Optical Receiver
	var receiver: LaserReceiver = LaserReceiver.new()
	receiver.name = "OverheadReceiver"
	receiver.position = Vector2(1260, 140)
	receiver.receiver_size = Vector2(52, 52)
	add_child(receiver)

	# Blast Door blocking the exit
	var door: PuzzleDoor = PuzzleDoor.new()
	door.name = "BlastDoorS2"
	door.position = Vector2(1500, 430)
	door.door_size = Vector2(28, 120)
	add_child(door)

	# Direct signal wiring: receiver powering up OPENS the blast door
	receiver.powered_changed.connect(door.set_powered)

	# 5. POST-DOOR HAZARD & EXIT
	# Lethal burning hazard laser below the pit
	var hazard_laser: LaserEmitter = LaserEmitter.new()
	hazard_laser.name = "PitHazardLaser"
	hazard_laser.position = Vector2(1540, 560)
	hazard_laser.laser_direction = Vector2.RIGHT
	hazard_laser.burn_player_on_touch = true
	hazard_laser.beam_color = Color(1.0, 0.2, 0.35)
	hazard_laser.max_range = 380.0
	hazard_laser.mode = LaserEmitter.LaserMode.STATIC
	add_child(hazard_laser)

	# Crumbling platform across the pit
	var crumble: CrumblingPlatform = CrumblingPlatform.new()
	crumble.name = "CrumbleS2"
	crumble.position = Vector2(1680, 440)
	add_child(crumble)

	# Checkpoint 2 and Exit platform
	create_static_block(Vector2(1900, 440), Vector2(240, 36))
	create_static_block(Vector2(2020, 220), Vector2(24, 450)) # Right boundary

	var cp2: CheckpointTerminal = CheckpointTerminal.new()
	cp2.name = "CheckpointS2_2"
	cp2.position = Vector2(1820, 390)
	cp2.checkpoint_id = 2
	add_child(cp2)

	var exit: ExitPortal = ExitPortal.new()
	exit.name = "ExitPortalS2"
	exit.position = Vector2(1940, 370)
	exit.next_stage_id = 3
	exit.portal_label = "STAGE 03"
	add_child(exit)

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
