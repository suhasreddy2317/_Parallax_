class_name Stage3Singularity
extends StageBase

## Stage 3 — SINGULARITY
## Climax stage: combines demanding platforming, timed hazard grids, rotating sweep lasers,
## security drone stealth evasion using reality cover, and final reactor core terminal.

func _init() -> void:
	stage_index = 3
	stage_title = "STAGE 03: SINGULARITY"
	stage_objective = "• Objective: Evade the drone, cross the singularity conduit, and stabilize the Reactor Core relay."
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

		# Fixed-reality co-op routes get an equivalent middle ledge through the
		# final conduit; solo players still have to phase A -> B -> A.
		var conduit_middle_a := ShiftableObject.new()
		conduit_middle_a.name = "ACoopConduitMiddleS3"
		conduit_middle_a.position = Vector2(2990.0, 320.0)
		conduit_middle_a.object_size = Vector2(110.0, 22.0)
		conduit_middle_a.active_reality = RealityManager.Reality.REALITY_A
		add_child(conduit_middle_a)
		conduit_middle_a.set_reality_override(reality)
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

		var conduit_entry_b := ShiftableObject.new()
		conduit_entry_b.name = "BCoopConduitEntryS3"
		conduit_entry_b.position = Vector2(2820.0, 370.0)
		conduit_entry_b.object_size = Vector2(110.0, 22.0)
		conduit_entry_b.active_reality = RealityManager.Reality.REALITY_B
		add_child(conduit_entry_b)
		conduit_entry_b.set_reality_override(reality)

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

	# The previous core pad becomes the final recovery point. The ending portal
	# now sits beyond a final conduit that combines phase footing, a timed sweep,
	# and the familiar optical lock.
	create_static_block(Vector2(2480, 420), Vector2(260, 36))
	var cp3 := CheckpointTerminal.new()
	cp3.name = "CheckpointS3_3"
	cp3.position = Vector2(2540, 365)
	cp3.checkpoint_id = 3
	add_child(cp3)

	# 5. Final Phase Conduit -- A -> B -> A in the solo route.
	create_static_block(Vector2(2700, 440), Vector2(180, 34))
	var conduit_a := ShiftableObject.new()
	conduit_a.name = "ConduitA1S3"
	conduit_a.position = Vector2(2820, 370)
	conduit_a.object_size = Vector2(110, 22)
	conduit_a.active_reality = RealityManager.Reality.REALITY_A
	add_child(conduit_a)

	var conduit_b := ShiftableObject.new()
	conduit_b.name = "ConduitB1S3"
	conduit_b.position = Vector2(2990, 320)
	conduit_b.object_size = Vector2(110, 22)
	conduit_b.active_reality = RealityManager.Reality.REALITY_B
	add_child(conduit_b)

	var conduit_a2 := ShiftableObject.new()
	conduit_a2.name = "ConduitA2S3"
	conduit_a2.position = Vector2(3150, 370)
	conduit_a2.object_size = Vector2(110, 22)
	conduit_a2.active_reality = RealityManager.Reality.REALITY_A
	add_child(conduit_a2)

	create_static_block(Vector2(3310, 390), Vector2(260, 34))
	create_static_block(Vector2(3310, 70), Vector2(260, 24))
	_add_signpost(Vector2(3230, 315), "SINGULARITY CONDUIT: phase across before the reactor sweep cycles")

	var conduit_laser := LaserEmitter.new()
	conduit_laser.name = "ConduitTimedLaserS3"
	conduit_laser.position = Vector2(2880, 288)
	conduit_laser.laser_direction = Vector2.RIGHT
	conduit_laser.max_range = 360.0
	conduit_laser.burn_player_on_touch = true
	conduit_laser.mode = LaserEmitter.LaserMode.TIMED
	conduit_laser.cycle_dormant_time = 1.4
	conduit_laser.cycle_telegraph_time = 1.0
	conduit_laser.cycle_active_time = 1.3
	conduit_laser.active_in_reality = RealityManager.Reality.REALITY_B
	add_child(conduit_laser)

	var conduit_emitter := LaserEmitter.new()
	conduit_emitter.name = "CoreRelayEmitterS3"
	conduit_emitter.position = Vector2(3200, 270)
	conduit_emitter.laser_direction = Vector2.RIGHT
	conduit_emitter.burn_player_on_touch = false
	conduit_emitter.beam_color = Color(0.25, 0.95, 0.8)
	conduit_emitter.max_range = 520.0
	conduit_emitter.mode = LaserEmitter.LaserMode.STATIC
	add_child(conduit_emitter)

	var conduit_mirror := LaserMirror.new()
	conduit_mirror.name = "CoreRelayMirrorS3"
	conduit_mirror.position = Vector2(3410, 270)
	conduit_mirror.mirror_angle_degrees = 90.0
	add_child(conduit_mirror)

	var conduit_receiver := LaserReceiver.new()
	conduit_receiver.name = "CoreRelayReceiverS3"
	conduit_receiver.position = Vector2(3410, 130)
	conduit_receiver.receiver_size = Vector2(52, 52)
	add_child(conduit_receiver)

	var conduit_door := PuzzleDoor.new()
	conduit_door.name = "CoreSealDoorS3"
	conduit_door.position = Vector2(3530, 300)
	conduit_door.door_size = Vector2(28, 230)
	add_child(conduit_door)
	conduit_receiver.powered_changed.connect(conduit_door.set_powered)
	_add_signpost(Vector2(3410, 350), "ALIGN THE CORE RELAY [E] TO STABILIZE THE REACTOR")

	# Reactor Core Overload Terminal Platform
	create_static_block(Vector2(3700, 390), Vector2(340, 34))
	create_static_block(Vector2(3870, 210), Vector2(24, 460)) # Right boundary wall

	var core_exit: ExitPortal = ExitPortal.new()
	core_exit.name = "ReactorCoreExit"
	core_exit.position = Vector2(3740, 330)
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
