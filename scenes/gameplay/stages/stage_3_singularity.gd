class_name Stage3Singularity
extends StageBase

## Stage 3 — SINGULARITY
## Climax stage: combines demanding platforming, timed hazard grids, rotating sweep lasers,
## security drone stealth evasion using reality cover, and final reactor core terminal.

func _init() -> void:
	stage_index = 3
	stage_title = "STAGE 03: SINGULARITY"
	stage_objective = "• Objective: Evade drone detection using Reality B cover, unlock the security gate, stabilize Reactor Core."
	default_spawn_position = Vector2(100.0, 480.0)

func _ready() -> void:
	super._ready()
	_build_level()

func configure_cooperative_reality(reality: int) -> void:
	super.configure_cooperative_reality(reality)
	var gate := get_node("ReactorSecurityGate") as PuzzleDoor
	gate.set_door_size(Vector2(28.0, 428.0))
	gate.position.y = 260.0
	var override_switch := get_node("DroneOverrideSwitch") as PuzzleSwitch
	override_switch.set_cooperative_latched(true)
	override_switch.monitoring = false
	_enable_override_switch_after_physics_frame(override_switch)
	if override_switch.toggled.is_connected(gate.set_powered):
		override_switch.toggled.disconnect(gate.set_powered)

	if reality == RealityManager.Reality.REALITY_A:
		var phase_step := ShiftableObject.new()
		phase_step.name = "AOnlyStepS3"
		phase_step.position = Vector2(650.0, 450.0)
		phase_step.object_size = Vector2(140.0, 22.0)
		phase_step.active_reality = RealityManager.Reality.REALITY_A
		add_child(phase_step)
		phase_step.set_reality_override(reality)
	else:
		override_switch.position.x = 1830.0
		override_switch.position.y = 452.0
		var platform_b := get_node("Singularity_PlatB1") as ShiftableObject
		platform_b.position = Vector2(480.0, 460.0)
		var phase_step := ShiftableObject.new()
		phase_step.name = "BOnlyStepS3"
		phase_step.position = Vector2(790.0, 450.0)
		phase_step.object_size = Vector2(140.0, 22.0)
		phase_step.active_reality = RealityManager.Reality.REALITY_B
		add_child(phase_step)
		phase_step.set_reality_override(reality)

func _enable_override_switch_after_physics_frame(override_switch: PuzzleSwitch) -> void:
	await get_tree().physics_frame
	if is_instance_valid(override_switch) and override_switch.is_inside_tree():
		override_switch.monitoring = true

func _build_level() -> void:
	# 1. Starting platform and boundary
	create_static_block(Vector2(160, 540), Vector2(320, 40))
	create_static_block(Vector2(0, 270), Vector2(24, 600)) # Left boundary wall

	# 2. Section 1: Timed Laser Hazard Grid & Phase Platforms
	var timed_laser: LaserEmitter = LaserEmitter.new()
	timed_laser.name = "GridTimedLaser"
	timed_laser.position = Vector2(360, 390)
	timed_laser.laser_direction = Vector2.RIGHT
	timed_laser.max_range = 460.0
	timed_laser.burn_player_on_touch = true
	timed_laser.mode = LaserEmitter.LaserMode.TIMED
	timed_laser.cycle_dormant_time = 1.0
	timed_laser.cycle_telegraph_time = 1.2
	timed_laser.cycle_active_time = 1.6
	timed_laser.active_in_reality = RealityManager.Reality.REALITY_A
	add_child(timed_laser)

	# Alternate Reality Ledges beneath / past the timed laser
	var plat_a1: ShiftableObject = ShiftableObject.new()
	plat_a1.name = "Singularity_PlatA1"
	plat_a1.position = Vector2(480, 460)
	plat_a1.object_size = Vector2(110, 22)
	plat_a1.active_reality = RealityManager.Reality.REALITY_A
	add_child(plat_a1)

	var plat_b1: ShiftableObject = ShiftableObject.new()
	plat_b1.name = "Singularity_PlatB1"
	plat_b1.position = Vector2(680, 410)
	plat_b1.object_size = Vector2(110, 22)
	plat_b1.active_reality = RealityManager.Reality.REALITY_B
	add_child(plat_b1)

	# Checkpoint 1 on intermediate staging platform
	create_static_block(Vector2(880, 480), Vector2(220, 36))
	var cp1: CheckpointTerminal = CheckpointTerminal.new()
	cp1.name = "CheckpointS3_1"
	cp1.position = Vector2(880, 430)
	cp1.checkpoint_id = 1
	add_child(cp1)

	_add_signpost(Vector2(880, 390), "CAUTION: Patrol Drone scanning ahead.")

	# 3. Section 2: Drone Trench & Stealth Cover
	# Trench floor & ceiling
	create_static_block(Vector2(1380, 520), Vector2(740, 40))
	create_static_block(Vector2(1380, 60), Vector2(740, 24))

	# Autonomous Security Drone
	var drone: SecurityDrone = SecurityDrone.new()
	drone.name = "PatrolDrone"
	drone.position = Vector2(1360, 260)
	drone.patrol_distance = 160.0
	drone.patrol_speed = 70.0
	drone.vision_range = 240.0
	add_child(drone)

	# Reality B Cover Wall (Provides solid cover to break drone line of sight)
	var cover: ShiftableObject = ShiftableObject.new()
	cover.name = "RealityCover_B"
	cover.position = Vector2(1320, 360)
	cover.object_size = Vector2(36, 170)
	cover.active_reality = RealityManager.Reality.REALITY_B
	add_child(cover)

	_add_signpost(Vector2(1320, 270), "Shift to Reality B [Q] to raise cover against drone scans")

	# Security Override Switch
	var override_switch: PuzzleSwitch = PuzzleSwitch.new()
	override_switch.name = "DroneOverrideSwitch"
	override_switch.position = Vector2(1580, 490)
	override_switch.is_toggle_type = true
	add_child(override_switch)

	_add_signpost(Vector2(1580, 440), "Terminal unlocks the Reactor Gate")

	# Security Gate Door
	var gate: PuzzleDoor = PuzzleDoor.new()
	gate.name = "ReactorSecurityGate"
	gate.position = Vector2(1720, 430)
	gate.door_size = Vector2(28, 120)
	add_child(gate)

	override_switch.toggled.connect(gate.set_powered)

	# 4. Section 3: Checkpoint 2 and Reactor Climax Vault
	create_static_block(Vector2(1880, 480), Vector2(200, 36))
	var cp2: CheckpointTerminal = CheckpointTerminal.new()
	cp2.name = "CheckpointS3_2"
	cp2.position = Vector2(1880, 430)
	cp2.checkpoint_id = 2
	add_child(cp2)

	# Rotating Sweep Hazard Laser
	var sweep_laser: LaserEmitter = LaserEmitter.new()
	sweep_laser.name = "CoreSweepLaser"
	sweep_laser.position = Vector2(2120, 180)
	sweep_laser.laser_direction = Vector2.DOWN
	sweep_laser.max_range = 420.0
	sweep_laser.mode = LaserEmitter.LaserMode.ROTATING_TIMED
	sweep_laser.sweep_angle_degrees = 38.0
	sweep_laser.sweep_speed = 1.3
	sweep_laser.cycle_dormant_time = 2.0
	sweep_laser.cycle_telegraph_time = 0.8
	sweep_laser.cycle_active_time = 1.6
	sweep_laser.burn_player_on_touch = true
	add_child(sweep_laser)

	# Moving platform over the reactor abyss
	var mover_core: MovingPlatform = MovingPlatform.new()
	mover_core.name = "MoverCore"
	mover_core.position = Vector2(2020, 460)
	mover_core.travel_offset = Vector2(140, 0)
	mover_core.travel_duration = 3.2
	add_child(mover_core)

	# Crumbling platform to vault
	var crumble_core: CrumblingPlatform = CrumblingPlatform.new()
	crumble_core.name = "CrumbleCore"
	crumble_core.position = Vector2(2240, 420)
	add_child(crumble_core)

	# Reactor Core Overload Terminal Platform
	create_static_block(Vector2(2480, 420), Vector2(260, 36))
	create_static_block(Vector2(2610, 210), Vector2(24, 460)) # Right boundary wall

	var core_exit: ExitPortal = ExitPortal.new()
	core_exit.name = "ReactorCoreExit"
	core_exit.position = Vector2(2520, 360)
	core_exit.next_stage_id = 999 # Marks final victory!
	core_exit.portal_label = "REACTOR CORE"
	add_child(core_exit)

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
