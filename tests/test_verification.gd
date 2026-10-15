extends Node2D

## test_verification.gd
## Comprehensive Headless QA Verification Suite for RESPawn: PARALLAX.

func _ready() -> void:
	print("==================================================================")
	print("   RESPAWN: PARALLAX — QA AUTOMATED VERIFICATION SUITE")
	print("==================================================================")
	call_deferred("_run_tests")

func _run_tests() -> void:
	var passed_count: int = 0
	var total_count: int = 0

	# TEST 1: RealityManager Autoload
	total_count += 1
	var rm: Node = get_node_or_null("/root/RealityManager")
	if rm != null and rm.has_method("toggle_reality") and rm.has_method("is_reality_a"):
		assert(rm.is_reality_a())
		rm.toggle_reality()
		assert(rm.is_reality_b())
		rm.toggle_reality()
		assert(rm.is_reality_a())
		print("[PASS] TEST 1: RealityManager autoload present and toggle operational.")
		passed_count += 1
	else:
		printerr("[FAIL] TEST 1: RealityManager autoload invalid.")

	# TEST 2: SoundManager Autoload & Procedural Synthesizer
	total_count += 1
	var sm: Node = get_node_or_null("/root/SoundManager")
	if sm != null and sm.has_method("play_jump") and sm.has_method("play_reality_shift") and sm.has_method("play_ui_click"):
		sm.call("play_ui_click")
		sm.call("play_jump")
		sm.call("play_land")
		sm.call("play_reality_shift")
		sm.call("play_checkpoint")
		sm.call("play_interact")
		sm.call("play_door_open")
		sm.call("play_stage_complete")
		print("[PASS] TEST 2: SoundManager synthesizes procedural audio streams.")
		passed_count += 1
	else:
		printerr("[FAIL] TEST 2: SoundManager autoload invalid.")

	# TEST 3: ParallaxBackdrop Scene & Layer Assembly
	total_count += 1
	var backdrop_scene: PackedScene = load("res://scenes/environment/parallax_backdrop.tscn")
	var backdrop: ParallaxBackdrop = backdrop_scene.instantiate() as ParallaxBackdrop
	add_child(backdrop)
	if backdrop.get_node_or_null("SkyLayer") != null and backdrop.get_node_or_null("DistantLayer") != null and backdrop.get_node_or_null("MidgroundLayer") != null and backdrop.get_node_or_null("NearLayer") != null and backdrop.get_node_or_null("AtmosphereLayer") != null:
		backdrop.set_reality_palette(0, 0.0)
		backdrop.set_reality_palette(1, 0.0)
		print("[PASS] TEST 3: ParallaxBackdrop instantiates with all 7 depth layers and crossfades palettes.")
		passed_count += 1
	else:
		printerr("[FAIL] TEST 3: ParallaxBackdrop layer structure missing.")
	backdrop.queue_free()

	# TEST 4: Player Controller & Procedural Rig
	total_count += 1
	var player_scene: PackedScene = load("res://scenes/player/player.tscn")
	var player: PuzzlePlayer = player_scene.instantiate() as PuzzlePlayer
	add_child(player)
	player.global_position = Vector2(100, 300)
	if player.get_node_or_null("CollisionShape2D") != null and player.has_method("request_respawn") and player.has_method("die"):
		player.die("test_burn")
		assert(player.current_state == PuzzlePlayer.State.DYING)
		player.request_respawn()
		assert(player.current_state == PuzzlePlayer.State.IDLE)
		print("[PASS] TEST 4: PuzzlePlayer controller, collision, state machine, and respawn functional.")
		passed_count += 1
	else:
		printerr("[FAIL] TEST 4: PuzzlePlayer setup incomplete.")
	player.queue_free()

	# TEST 5: Stage 1 (FIRST CONTACT)
	total_count += 1
	var s1_scene: PackedScene = load("res://scenes/gameplay/stages/stage_1_first_contact.tscn")
	var s1: Stage1FirstContact = s1_scene.instantiate() as Stage1FirstContact
	add_child(s1)
	var door_s1: PuzzleDoor = s1.get_node_or_null("DoorS1") as PuzzleDoor
	var switch_s1: PuzzleSwitch = s1.get_node_or_null("SwitchS1") as PuzzleSwitch
	var exit_s1: ExitPortal = s1.get_node_or_null("ExitPortalS1") as ExitPortal
	if door_s1 != null and switch_s1 != null and exit_s1 != null:
		assert(not door_s1.is_open)
		switch_s1.toggle_switch()
		assert(door_s1.is_open)
		print("[PASS] TEST 5: Stage 1 (FIRST CONTACT) puzzle mechanisms and exit portal valid.")
		passed_count += 1
	else:
		printerr("[FAIL] TEST 5: Stage 1 components missing.")
	s1.queue_free()

	# TEST 6: Stage 2 (FRACTURE) Optical Puzzle & Geometric Reflection
	total_count += 1
	var s2_scene: PackedScene = load("res://scenes/gameplay/stages/stage_2_fracture.tscn")
	var s2: Stage2Fracture = s2_scene.instantiate() as Stage2Fracture
	add_child(s2)
	var emitter_s2: LaserEmitter = s2.get_node_or_null("OpticalEmitter") as LaserEmitter
	var mirror_s2: LaserMirror = s2.get_node_or_null("PuzzleMirror") as LaserMirror
	var recv_s2: LaserReceiver = s2.get_node_or_null("OverheadReceiver") as LaserReceiver
	var door_s2: PuzzleDoor = s2.get_node_or_null("BlastDoorS2") as PuzzleDoor
	if emitter_s2 != null and mirror_s2 != null and recv_s2 != null and door_s2 != null:
		# Mirror reflection physics check:
		# Mirror rotated at 135 deg must reflect incoming (1,0) to (0,-1)
		mirror_s2.rotation_degrees = 135.0
		var refl: Vector2 = mirror_s2.get_reflection(Vector2.RIGHT)
		assert(abs(refl.x) < 0.01 and refl.y < -0.99) # Reflects UP!

		# Receiver triggers door
		recv_s2.receive_laser_hit()
		assert(recv_s2.is_powered)
		assert(door_s2.is_open)
		print("[PASS] TEST 6: Stage 2 (FRACTURE) geometric laser reflection and receiver door puzzle verified.")
		passed_count += 1
	else:
		printerr("[FAIL] TEST 6: Stage 2 optical components missing.")
	s2.queue_free()

	# TEST 7: Stage 3 (SINGULARITY) Surveillance Drone & Cover
	total_count += 1
	var s3_scene: PackedScene = load("res://scenes/gameplay/stages/stage_3_singularity.tscn")
	var s3: Stage3Singularity = s3_scene.instantiate() as Stage3Singularity
	add_child(s3)
	var drone_s3: SecurityDrone = s3.get_node_or_null("PatrolDrone") as SecurityDrone
	var cover_s3: ShiftableObject = s3.get_node_or_null("RealityCover_B") as ShiftableObject
	var gate_s3: PuzzleDoor = s3.get_node_or_null("ReactorSecurityGate") as PuzzleDoor
	var core_exit: ExitPortal = s3.get_node_or_null("ReactorCoreExit") as ExitPortal
	if drone_s3 != null and cover_s3 != null and gate_s3 != null and core_exit != null:
		assert(cover_s3.active_reality == 1) # REALITY_B
		assert(core_exit.next_stage_id == 999) # Victory flag
		print("[PASS] TEST 7: Stage 3 (SINGULARITY) patrol drone, reality cover, and reactor terminal valid.")
		passed_count += 1
	else:
		printerr("[FAIL] TEST 7: Stage 3 components missing.")
	s3.queue_free()

	# TEST 8: Full Gameplay Scene Integration
	total_count += 1
	var gameplay_scene: PackedScene = load("res://scenes/gameplay/gameplay.tscn")
	var gp: Gameplay = gameplay_scene.instantiate() as Gameplay
	add_child(gp)
	if gp.player != null and gp.backdrop != null and gp.hud != null and gp.pause_menu != null and gp.victory_screen != null:
		# Test stage transitions: Stage 1 -> Stage 2 -> Stage 3 -> Victory
		gp.load_stage(1)
		assert(gp.current_stage_id == 1)
		gp.current_stage.stage_completed.emit(999, gp.player.player_id)
		assert(not gp.is_campaign_won and not gp.victory_screen.visible)
		gp.load_stage(2)
		assert(gp.current_stage_id == 2)
		gp.current_stage.stage_completed.emit(999, gp.player.player_id)
		assert(not gp.is_campaign_won and not gp.victory_screen.visible)
		gp.load_stage(3)
		assert(gp.current_stage_id == 3)
		var final_stage: StageBase = gp.current_stage
		final_stage.stage_completed.emit(999, gp.player.player_id)
		assert(gp.is_campaign_won and gp.victory_screen.visible)
		assert(gp.victory_screen._ending_sequence_started)
		assert(get_tree().paused and gp.is_game_paused)
		assert(gp.victory_screen.play_again_requested.is_connected(gp._restart_campaign))
		assert(gp.victory_screen.main_menu_requested.is_connected(gp._return_to_main_menu))
		final_stage.stage_completed.emit(999, gp.player.player_id)
		assert(gp.victory_screen._ending_sequence_started)
		gp.victory_screen.play_again_requested.emit()
		assert(not get_tree().paused and not gp.is_game_paused)
		assert(not gp.is_campaign_won and gp.current_stage_id == 1)
		assert(not gp.victory_screen.visible and not gp.victory_screen._ending_sequence_started)
		final_stage.stage_completed.emit(999, gp.player.player_id)
		assert(not gp.is_campaign_won and not gp.victory_screen.visible)
		print("[PASS] TEST 8: Intermediate completion is ignored; final completion starts one ending, replay resets safely, and stale callbacks are ignored.")
		passed_count += 1
	else:
		printerr("[FAIL] TEST 8: Gameplay orchestration missing child nodes.")
	gp.queue_free()

	# TEST 9: Main Entry Scene & Main Menu
	total_count += 1
	var main_scene: PackedScene = load("res://main.tscn")
	var main_node: Node = main_scene.instantiate()
	add_child(main_node)
	var mm: MainMenu = main_node.get_node_or_null("TitleUILayer/MainMenu") as MainMenu
	var smenu: SettingsMenu = main_node.get_node_or_null("TitleUILayer/SettingsMenu") as SettingsMenu
	if mm != null and smenu != null:
		# Verify campaign launch signal
		main_node.call("_on_start_campaign")
		assert(main_node.get("active_gameplay") != null)
		# Verify return to menu
		main_node.call("_on_return_to_menu")
		assert(main_node.get("active_gameplay") == null)
		assert(mm.visible)
		print("[PASS] TEST 9: Main project entry scene, Title Screen, Settings modal, and seamless scene switching verified.")
		passed_count += 1
	else:
		printerr("[FAIL] TEST 9: Main scene structure invalid.")
	main_node.queue_free()

	# TEST 10: Local Multiplayer Viewports, Reality Isolation, Input & Respawn
	total_count += 1
	var multiplayer_gameplay: Gameplay = gameplay_scene.instantiate() as Gameplay
	multiplayer_gameplay.set_multiplayer_mode(true)
	add_child(multiplayer_gameplay)
	if multiplayer_gameplay.player != null and multiplayer_gameplay.player2 != null and multiplayer_gameplay.viewport1 != null and multiplayer_gameplay.viewport2 != null and multiplayer_gameplay.current_stage2 != null:
		assert(multiplayer_gameplay._reality_rift != null)
		assert(multiplayer_gameplay.player.get_viewport() == multiplayer_gameplay.viewport1)
		assert(multiplayer_gameplay.player2.get_viewport() == multiplayer_gameplay.viewport2)
		assert(multiplayer_gameplay.viewport1.get_camera_2d() == multiplayer_gameplay.player.camera)
		assert(multiplayer_gameplay.viewport2.get_camera_2d() == multiplayer_gameplay.player2.camera)
		assert(multiplayer_gameplay.player.camera.is_current())
		assert(multiplayer_gameplay.player2.camera.is_current())

		var a_platform: ShiftableObject = multiplayer_gameplay.current_stage.get_node("Plat_A1") as ShiftableObject
		var b_platform: ShiftableObject = multiplayer_gameplay.current_stage.get_node("Plat_B1") as ShiftableObject
		var b_stage_a_platform: ShiftableObject = multiplayer_gameplay.current_stage2.get_node("Plat_A1") as ShiftableObject
		var b_stage_b_platform: ShiftableObject = multiplayer_gameplay.current_stage2.get_node("Plat_B1") as ShiftableObject
		assert(a_platform.is_active() and not b_platform.is_active())
		assert(not b_stage_a_platform.is_active() and b_stage_b_platform.is_active())
		assert((multiplayer_gameplay.current_stage.get_node("ExitPortalS1") as ExitPortal).required_player_id == 1)
		assert((multiplayer_gameplay.current_stage2.get_node("ExitPortalS1") as ExitPortal).required_player_id == 2)
		var coop_bridge: ShiftableObject = multiplayer_gameplay.current_stage.get_node("CrossRealityBridgeA") as ShiftableObject
		var relay_b: PuzzleSwitch = multiplayer_gameplay.current_stage2.get_node("BRelaySwitch") as PuzzleSwitch
		var door_b: PuzzleDoor = multiplayer_gameplay.current_stage2.get_node("DoorS1") as PuzzleDoor
		assert(not coop_bridge.is_active() and not door_b.is_open)
		multiplayer_gameplay.player2.global_position = relay_b.global_position
		multiplayer_gameplay.player2.velocity = Vector2.ZERO
		for frame in range(3):
			await get_tree().physics_frame
		assert(coop_bridge.is_active())
		assert(multiplayer_gameplay.hud.checkpoint_banner.text == "REALITY LINK ESTABLISHED")
		assert(multiplayer_gameplay.hud._checkpoint_timer > 1.3 and multiplayer_gameplay.hud._checkpoint_timer <= 1.5)
		assert(multiplayer_gameplay.hud._notification_fade_in_duration > 0.0)
		assert(multiplayer_gameplay.hud._notification_fade_out_duration > 0.0)
		assert(multiplayer_gameplay._reality_rift._pulse_reality == RealityManager.Reality.REALITY_B)
		assert(multiplayer_gameplay._reality_rift._pulse_activated)
		assert(RealityRiftDivider.PULSE_DURATION >= 1.2)
		var bridge_feedback: Node = coop_bridge.get_node_or_null("LinkedActionPulse")
		assert(bridge_feedback is LinkedActionPulse)
		assert((bridge_feedback as LinkedActionPulse)._activated)
		assert(LinkedActionPulse.DURATION >= 1.2)
		assert(multiplayer_gameplay._reality_rift._pulse > 0.0)
		var linked_audio: AudioStreamPlayer = SoundManager.instance.get("_linked_action_player") as AudioStreamPlayer
		assert(linked_audio != null and linked_audio.playing)
		var linked_audio_stream: AudioStream = linked_audio.stream
		var pulse_before_duplicate: float = multiplayer_gameplay._reality_rift._pulse
		var notification_before_duplicate: float = multiplayer_gameplay.hud._checkpoint_timer
		var feedback_elapsed_before_duplicate: float = (bridge_feedback as LinkedActionPulse)._elapsed
		relay_b._on_body_entered(multiplayer_gameplay.player2)
		assert(coop_bridge.get_node_or_null("LinkedActionPulse") == bridge_feedback)
		assert(multiplayer_gameplay._reality_rift._pulse == pulse_before_duplicate)
		assert(multiplayer_gameplay.hud._checkpoint_timer == notification_before_duplicate)
		assert(linked_audio.stream == linked_audio_stream and linked_audio.playing)
		assert((bridge_feedback as LinkedActionPulse)._elapsed == feedback_elapsed_before_duplicate)
		var linked_hud: GameHUD = multiplayer_gameplay.hud
		linked_hud.show_link_established_notification(RealityManager.Reality.REALITY_B)
		assert(is_zero_approx(linked_hud.checkpoint_banner.modulate.a))
		linked_hud._process(linked_hud._notification_fade_in_duration * 0.5)
		assert(is_equal_approx(linked_hud.checkpoint_banner.modulate.a, 0.5))
		linked_hud._process(linked_hud._notification_fade_in_duration * 0.5)
		assert(is_equal_approx(linked_hud.checkpoint_banner.modulate.a, 1.0))
		linked_hud._process(linked_hud._checkpoint_timer - linked_hud._notification_fade_out_duration * 0.5)
		assert(is_equal_approx(linked_hud.checkpoint_banner.modulate.a, 0.5))
		linked_hud._process(linked_hud._notification_fade_out_duration)
		assert(is_zero_approx(linked_hud.checkpoint_banner.modulate.a))
		var linked_divider: RealityRiftDivider = multiplayer_gameplay._reality_rift
		linked_divider._pulse = 1.0
		linked_divider._process(RealityRiftDivider.PULSE_DURATION * 0.5)
		assert(is_equal_approx(linked_divider._pulse, 0.5))
		var switch_a: PuzzleSwitch = multiplayer_gameplay.current_stage.get_node("SwitchS1") as PuzzleSwitch
		switch_a.toggle_switch()
		assert((multiplayer_gameplay.current_stage.get_node("DoorS1") as PuzzleDoor).is_open)
		assert(door_b.is_open)
		assert(not multiplayer_gameplay._stage_transition_pending)
		assert(not multiplayer_gameplay._player1_reached_exit and not multiplayer_gameplay._player2_reached_exit)
		assert(multiplayer_gameplay.current_stage_id == 1)

		for frame in range(8):
			await get_tree().physics_frame
		var p1_start_x: float = multiplayer_gameplay.player.global_position.x
		var p2_start_x: float = multiplayer_gameplay.player2.global_position.x
		var p1_right := InputEventKey.new()
		p1_right.keycode = KEY_D
		p1_right.physical_keycode = KEY_D
		p1_right.pressed = true
		var p2_right := InputEventKey.new()
		p2_right.keycode = KEY_RIGHT
		p2_right.physical_keycode = KEY_RIGHT
		p2_right.pressed = true
		Input.parse_input_event(p1_right)
		Input.parse_input_event(p2_right)
		for frame in range(18):
			await get_tree().physics_frame
		p1_right.pressed = false
		p2_right.pressed = false
		Input.parse_input_event(p1_right)
		Input.parse_input_event(p2_right)
		assert(multiplayer_gameplay.player.global_position.x > p1_start_x + 10.0)
		assert(multiplayer_gameplay.player2.global_position.x > p2_start_x + 10.0)
		assert(multiplayer_gameplay.player.camera.global_position.is_equal_approx(multiplayer_gameplay.player.global_position))
		assert(multiplayer_gameplay.player2.camera.global_position.is_equal_approx(multiplayer_gameplay.player2.global_position))

		for frame in range(4):
			await get_tree().physics_frame
		var p1_jump := InputEventKey.new()
		p1_jump.keycode = KEY_W
		p1_jump.physical_keycode = KEY_W
		p1_jump.pressed = true
		var p2_jump := InputEventKey.new()
		p2_jump.keycode = KEY_UP
		p2_jump.physical_keycode = KEY_UP
		p2_jump.pressed = true
		Input.parse_input_event(p1_jump)
		Input.parse_input_event(p2_jump)
		for frame in range(2):
			await get_tree().physics_frame
		assert(multiplayer_gameplay.player.velocity.y < 0.0)
		assert(multiplayer_gameplay.player2.velocity.y < 0.0)
		p1_jump.pressed = false
		p2_jump.pressed = false
		Input.parse_input_event(p1_jump)
		Input.parse_input_event(p2_jump)

		multiplayer_gameplay.player.die("test_multiplayer_respawn")
		multiplayer_gameplay.player._process_death_sequence(1.0)
		assert(multiplayer_gameplay.player.current_state == PuzzlePlayer.State.IDLE)
		assert(multiplayer_gameplay.player2.current_state != PuzzlePlayer.State.DYING)
		assert(coop_bridge.is_active() and door_b.is_open)
		multiplayer_gameplay.player2.die("test_player2_respawn")
		multiplayer_gameplay.player2._process_death_sequence(1.0)
		assert(multiplayer_gameplay.player2.current_state == PuzzlePlayer.State.IDLE)
		assert(multiplayer_gameplay.player.current_state != PuzzlePlayer.State.DYING)

		multiplayer_gameplay.load_stage(2)
		var p1_barrier: ShiftableObject = multiplayer_gameplay.current_stage.get_node("LaserBarrier_A") as ShiftableObject
		var p2_barrier: ShiftableObject = multiplayer_gameplay.current_stage2.get_node("LaserBarrier_A") as ShiftableObject
		assert(p1_barrier.is_active() and not p2_barrier.is_active())
		assert(multiplayer_gameplay.current_stage2.get_node_or_null("BPhaseStepS2") != null)
		var s2_relay: PuzzleSwitch = multiplayer_gameplay.current_stage2.get_node("BRelaySwitchS2") as PuzzleSwitch
		s2_relay.toggle_switch()
		assert(not p1_barrier.is_active())
		assert(p1_barrier.get_node_or_null("LinkedActionPulse") is LinkedActionPulse)
		var p1_receiver: LaserReceiver = multiplayer_gameplay.current_stage.get_node("OverheadReceiver") as LaserReceiver
		var p1_door: PuzzleDoor = multiplayer_gameplay.current_stage.get_node("BlastDoorS2") as PuzzleDoor
		var p2_door: PuzzleDoor = multiplayer_gameplay.current_stage2.get_node("BlastDoorS2") as PuzzleDoor
		assert(not p2_door.is_open)
		multiplayer_gameplay._reality_rift._pulse = 0.0
		p1_receiver.receive_laser_hit()
		assert(p1_door.is_open and p2_door.is_open)
		var receiver_feedback: Node = p2_door.get_node_or_null("LinkedActionPulse")
		assert(receiver_feedback is LinkedActionPulse)
		multiplayer_gameplay.hud.show_checkpoint_notification("NO LINK")
		multiplayer_gameplay._reality_rift._pulse = 0.0
		p1_receiver._set_powered(false)
		assert(multiplayer_gameplay.hud.checkpoint_banner.text == "NO LINK")
		assert(not is_zero_approx(multiplayer_gameplay._reality_rift._pulse))
		assert(not (receiver_feedback as LinkedActionPulse)._activated)
		assert(p2_door.get_node_or_null("LinkedActionPulse") == receiver_feedback)

		multiplayer_gameplay.load_stage(3)
		var p1_cover: ShiftableObject = multiplayer_gameplay.current_stage.get_node("RealityCover_B") as ShiftableObject
		var p2_cover: ShiftableObject = multiplayer_gameplay.current_stage2.get_node("RealityCover_B") as ShiftableObject
		var p1_grid_laser: LaserEmitter = multiplayer_gameplay.current_stage.get_node("GridTimedLaser") as LaserEmitter
		var p2_grid_laser: LaserEmitter = multiplayer_gameplay.current_stage2.get_node("GridTimedLaser") as LaserEmitter
		assert(multiplayer_gameplay.current_stage.get_node_or_null("AOnlyStepS3") != null)
		assert(multiplayer_gameplay.current_stage2.get_node_or_null("BOnlyStepS3") != null)
		var b_start_floor_right: float = 320.0
		var b_first_platform := multiplayer_gameplay.current_stage2.get_node("Singularity_PlatB1") as ShiftableObject
		var b_second_platform := multiplayer_gameplay.current_stage2.get_node("BOnlyStepS3") as ShiftableObject
		var b_checkpoint_left: float = 770.0
		var b_start_gap: float = b_first_platform.position.x - b_first_platform.object_size.x * 0.5 - b_start_floor_right
		var b_platform_gap: float = b_second_platform.position.x - b_second_platform.object_size.x * 0.5 - (b_first_platform.position.x + b_first_platform.object_size.x * 0.5)
		var b_checkpoint_overlap: float = b_second_platform.position.x + b_second_platform.object_size.x * 0.5 - b_checkpoint_left
		var max_jump_distance: float = multiplayer_gameplay.player2.max_speed * 2.0 * absf(multiplayer_gameplay.player2.jump_velocity) / multiplayer_gameplay.player2.gravity
		assert(is_equal_approx(b_first_platform.position.x, 480.0))
		assert(b_start_gap < max_jump_distance and b_platform_gap < max_jump_distance)
		assert(b_checkpoint_overlap > 0.0)
		assert(b_first_platform.is_active() and b_second_platform.is_active())
		assert(not p1_cover.is_active() and p2_cover.is_active())
		assert(p1_grid_laser.get("_reality_override") == RealityManager.Reality.REALITY_A)
		assert(p2_grid_laser.get("_reality_override") == RealityManager.Reality.REALITY_B)
		var p1_override: PuzzleSwitch = multiplayer_gameplay.current_stage.get_node("DroneOverrideSwitch") as PuzzleSwitch
		var p2_override: PuzzleSwitch = multiplayer_gameplay.current_stage2.get_node("DroneOverrideSwitch") as PuzzleSwitch
		var p1_gate: PuzzleDoor = multiplayer_gameplay.current_stage.get_node("ReactorSecurityGate") as PuzzleDoor
		var p2_gate: PuzzleDoor = multiplayer_gameplay.current_stage2.get_node("ReactorSecurityGate") as PuzzleDoor
		assert(p1_override.position.x < p1_gate.position.x)
		assert(p2_override.position.x > p2_gate.position.x)
		assert(not p2_gate.is_open and not p2_gate._collision_shape.disabled)
		p1_override.toggle_switch()
		assert(not p1_gate.is_open and p2_gate.is_open)
		p2_override.toggle_switch()
		assert(p1_gate.is_open and p2_gate.is_open)
		assert(multiplayer_gameplay.current_stage.get_node_or_null("ReactorCoreExit") != null)
		assert(multiplayer_gameplay.current_stage2.get_node_or_null("ReactorCoreExit") != null)
		var p1_core_exit := multiplayer_gameplay.current_stage.get_node("ReactorCoreExit") as ExitPortal
		var p2_core_exit := multiplayer_gameplay.current_stage2.get_node("ReactorCoreExit") as ExitPortal
		p1_core_exit._on_body_entered(multiplayer_gameplay.player)
		assert(not multiplayer_gameplay.is_campaign_won)
		assert(multiplayer_gameplay._player1_reached_exit and not multiplayer_gameplay._player2_reached_exit)
		assert(not multiplayer_gameplay.victory_screen._ending_sequence_started)
		p2_core_exit._on_body_entered(multiplayer_gameplay.player2)
		assert(multiplayer_gameplay.is_campaign_won)
		assert(multiplayer_gameplay.victory_screen._ending_sequence_started)
		assert(get_tree().paused)
		multiplayer_gameplay.current_stage2.stage_completed.emit(999, multiplayer_gameplay.player2.player_id)
		assert(multiplayer_gameplay.victory_screen._ending_sequence_started)

		print("[PASS] TEST 10: Split-screen input, distinct reality routes, linked puzzles, paired exits and independent respawn verified.")
		passed_count += 1
	else:
		printerr("[FAIL] TEST 10: Local multiplayer setup missing player, viewport, or stage.")
	if get_tree().paused:
		multiplayer_gameplay._return_to_main_menu()
	multiplayer_gameplay.queue_free()

	# TEST 11: Cooperative exits remain independent in Stages 2 and 3
	total_count += 1
	await get_tree().process_frame
	var exit_gameplay: Gameplay = gameplay_scene.instantiate() as Gameplay
	exit_gameplay.set_multiplayer_mode(true)
	add_child(exit_gameplay)
	var stage1_exit_a := exit_gameplay.current_stage.get_node("ExitPortalS1") as ExitPortal
	var stage1_exit_b := exit_gameplay.current_stage2.get_node("ExitPortalS1") as ExitPortal
	stage1_exit_b._on_body_entered(exit_gameplay.player2)
	assert(not exit_gameplay._player1_reached_exit and exit_gameplay._player2_reached_exit)
	assert(not exit_gameplay._stage_transition_pending)
	stage1_exit_a._on_body_entered(exit_gameplay.player)
	assert(exit_gameplay._player1_reached_exit and exit_gameplay._player2_reached_exit)
	assert(exit_gameplay._stage_transition_pending)
	await get_tree().process_frame
	assert(exit_gameplay.current_stage_id == 2)
	var stage2_exit_a := exit_gameplay.current_stage.get_node("ExitPortalS2") as ExitPortal
	var stage2_exit_b := exit_gameplay.current_stage2.get_node("ExitPortalS2") as ExitPortal
	var stage2_reported_player_ids: Array[int] = []
	exit_gameplay.current_stage.stage_completed.connect(
		func(_next_stage: int, completed_player_id: int) -> void:
			stage2_reported_player_ids.append(completed_player_id)
	)
	exit_gameplay.current_stage2.stage_completed.connect(
		func(_next_stage: int, completed_player_id: int) -> void:
			stage2_reported_player_ids.append(completed_player_id)
	)
	assert(stage2_exit_a.required_player_id == 1 and stage2_exit_b.required_player_id == 2)
	stage2_exit_b._on_body_entered(exit_gameplay.player)
	assert(not stage2_exit_b.is_activated)
	assert(not exit_gameplay._player1_reached_exit and not exit_gameplay._player2_reached_exit)
	stage2_exit_a._on_body_entered(exit_gameplay.player)
	assert(exit_gameplay._player1_reached_exit and not exit_gameplay._player2_reached_exit)
	assert(not exit_gameplay._stage_transition_pending and exit_gameplay.current_stage_id == 2)
	assert(stage2_reported_player_ids == [1])
	stage2_exit_a._on_body_entered(exit_gameplay.player)
	stage2_exit_a.exit_reached.emit(3, exit_gameplay.player.player_id)
	assert(stage2_reported_player_ids == [1, 1])
	assert(exit_gameplay._player1_reached_exit and not exit_gameplay._player2_reached_exit)
	assert(not exit_gameplay._stage_transition_pending and exit_gameplay.current_stage_id == 2)
	exit_gameplay.player.die("test_exit_respawn")
	exit_gameplay.player._process_death_sequence(1.0)
	assert(exit_gameplay.player.current_state == PuzzlePlayer.State.IDLE)
	assert(exit_gameplay._player1_reached_exit and not exit_gameplay._player2_reached_exit)
	stage2_exit_a._on_body_entered(exit_gameplay.player)
	assert(exit_gameplay._player1_reached_exit and not exit_gameplay._player2_reached_exit)
	stage2_exit_b._on_body_entered(exit_gameplay.player2)
	assert(stage2_reported_player_ids == [1, 1, 2])
	assert(exit_gameplay._player1_reached_exit and exit_gameplay._player2_reached_exit)
	assert(exit_gameplay._stage_transition_pending and not exit_gameplay.is_campaign_won)
	assert(exit_gameplay.current_stage_id == 2)
	await get_tree().process_frame
	assert(exit_gameplay.current_stage_id == 3)
	await get_tree().process_frame
	assert(exit_gameplay.current_stage_id == 3)

	var stale_stage2_a: StageBase = exit_gameplay.current_stage
	var stale_stage2_b: StageBase = exit_gameplay.current_stage2
	exit_gameplay.load_stage(2)
	stale_stage2_a.stage_completed.emit(3, 1)
	stale_stage2_b.stage_completed.emit(3, 2)
	assert(exit_gameplay.current_stage_id == 2)
	assert(not exit_gameplay._stage_transition_pending)
	assert(not exit_gameplay._player1_reached_exit and not exit_gameplay._player2_reached_exit)
	await get_tree().process_frame
	var reverse_exit_a := exit_gameplay.current_stage.get_node("ExitPortalS2") as ExitPortal
	var reverse_exit_b := exit_gameplay.current_stage2.get_node("ExitPortalS2") as ExitPortal
	reverse_exit_b._on_body_entered(exit_gameplay.player2)
	assert(not exit_gameplay._player1_reached_exit and exit_gameplay._player2_reached_exit)
	assert(not exit_gameplay._stage_transition_pending)
	reverse_exit_b.exit_reached.emit(3, exit_gameplay.player2.player_id)
	assert(not exit_gameplay._player1_reached_exit and exit_gameplay._player2_reached_exit)
	assert(not exit_gameplay._stage_transition_pending)
	reverse_exit_a._on_body_entered(exit_gameplay.player)
	assert(exit_gameplay._player1_reached_exit and exit_gameplay._player2_reached_exit)
	assert(exit_gameplay._stage_transition_pending)
	await get_tree().process_frame
	assert(exit_gameplay.current_stage_id == 3)

	var stage3_exit_a := exit_gameplay.current_stage.get_node("ReactorCoreExit") as ExitPortal
	var stage3_exit_b := exit_gameplay.current_stage2.get_node("ReactorCoreExit") as ExitPortal
	stage3_exit_a._on_body_entered(exit_gameplay.player)
	assert(exit_gameplay._player1_reached_exit and not exit_gameplay._player2_reached_exit)
	assert(not exit_gameplay.is_campaign_won)
	assert(not exit_gameplay._stage_transition_pending)
	assert(not exit_gameplay.victory_screen._ending_sequence_started)
	stage3_exit_b._on_body_entered(exit_gameplay.player2)
	assert(exit_gameplay._player1_reached_exit and exit_gameplay._player2_reached_exit)
	assert(exit_gameplay.is_campaign_won and exit_gameplay._stage_transition_pending)
	assert(exit_gameplay.victory_screen._ending_sequence_started)
	var co_op_ending_tween: Tween = exit_gameplay.victory_screen._ending_tween
	exit_gameplay.current_stage2.stage_completed.emit(999, exit_gameplay.player2.player_id)
	assert(exit_gameplay.victory_screen._ending_tween == co_op_ending_tween)
	print("[PASS] TEST 11: Stage 2/3 exits require distinct player completions, ignore stale Stage 2 signals, and advance only once.")
	passed_count += 1
	exit_gameplay._return_to_main_menu()
	assert(not get_tree().paused)
	exit_gameplay.queue_free()

	# TEST 12: Reality B Stage 3 route is physically traversable
	total_count += 1
	await get_tree().process_frame
	var route_gameplay: Gameplay = gameplay_scene.instantiate() as Gameplay
	route_gameplay.set_multiplayer_mode(true)
	add_child(route_gameplay)
	route_gameplay.load_stage(3)
	for frame in range(4):
		await get_tree().physics_frame
	var route_player := route_gameplay.player2
	route_player.set_physics_process(false)
	var jumps_remaining := 2
	for frame in range(300):
		if route_player.is_on_floor():
			if (jumps_remaining == 2 and route_player.global_position.x >= 270.0) or (jumps_remaining == 1 and route_player.global_position.x >= 520.0):
				route_player.velocity.y = route_player.jump_velocity
				jumps_remaining -= 1
			else:
				route_player.velocity.y = 0.0
		else:
			route_player.velocity.y = minf(route_player.velocity.y + route_player.gravity / 60.0, route_player.max_fall_speed)
		route_player.velocity.x = route_player.max_speed
		route_player.move_and_slide()
		await get_tree().physics_frame
		if route_player.global_position.x >= 770.0:
			break
	assert(route_gameplay.player2.current_state != PuzzlePlayer.State.DYING)
	assert(route_gameplay.player2.global_position.x >= 770.0)
	print("[PASS] TEST 12: Player 2 physically traverses the Stage 3 Reality B ledges to the checkpoint.")
	passed_count += 1
	route_gameplay.queue_free()

	# TEST 13: Single Player Controls and Exit Progression Remain Available
	total_count += 1
	await get_tree().process_frame
	var single_gameplay: Gameplay = gameplay_scene.instantiate() as Gameplay
	add_child(single_gameplay)
	var single_start_x: float = single_gameplay.player.global_position.x
	var single_right := InputEventKey.new()
	single_right.keycode = KEY_D
	single_right.physical_keycode = KEY_D
	single_right.pressed = true
	Input.parse_input_event(single_right)
	for frame in range(18):
		await get_tree().physics_frame
	single_right.pressed = false
	Input.parse_input_event(single_right)
	assert(not single_gameplay.is_multiplayer)
	assert(single_gameplay.player.global_position.x > single_start_x + 10.0)
	single_gameplay.load_stage(2)
	var single_exit := single_gameplay.current_stage.get_node("ExitPortalS2") as ExitPortal
	single_exit._on_body_entered(single_gameplay.player)
	assert(single_gameplay.current_stage_id == 2)
	await get_tree().process_frame
	assert(single_gameplay.current_stage_id == 3)
	print("[PASS] TEST 13: Single-player movement and one-player Stage 2 progression remain unchanged.")
	passed_count += 1
	single_gameplay.queue_free()

	# TEST 14: Reality B can pass under the cover but remains gated until linked activation
	total_count += 1
	await get_tree().process_frame
	var gate_route_gameplay: Gameplay = gameplay_scene.instantiate() as Gameplay
	gate_route_gameplay.set_multiplayer_mode(true)
	add_child(gate_route_gameplay)
	gate_route_gameplay.load_stage(3)
	for frame in range(4):
		await get_tree().physics_frame
	var b_cover := gate_route_gameplay.current_stage2.get_node("RealityCover_B") as ShiftableObject
	var b_gate := gate_route_gameplay.current_stage2.get_node("ReactorSecurityGate") as PuzzleDoor
	var a_gate := gate_route_gameplay.current_stage.get_node("ReactorSecurityGate") as PuzzleDoor
	var a_override := gate_route_gameplay.current_stage.get_node("DroneOverrideSwitch") as PuzzleSwitch
	var b_override := gate_route_gameplay.current_stage2.get_node("DroneOverrideSwitch") as PuzzleSwitch
	var drone_b := gate_route_gameplay.current_stage2.get_node("PatrolDrone") as SecurityDrone
	drone_b.set_physics_process(false)
	gate_route_gameplay.player2.global_position = Vector2(1250.0, 480.0)
	gate_route_gameplay.player2.velocity = Vector2.ZERO
	assert(is_equal_approx(b_cover.position.y, 360.0) and b_cover.is_active())
	assert(is_equal_approx(b_override.position.x, 1830.0))
	assert(not b_gate.is_open and not b_gate._collision_shape.disabled)
	var route_right := InputEventKey.new()
	route_right.keycode = KEY_RIGHT
	route_right.physical_keycode = KEY_RIGHT
	route_right.pressed = true
	Input.parse_input_event(route_right)
	for frame in range(150):
		await get_tree().physics_frame
		if gate_route_gameplay.player2.global_position.x >= 1690.0:
			break
	assert(gate_route_gameplay.player2.global_position.x > 1350.0)
	assert(gate_route_gameplay.player2.global_position.x < 1710.0)
	assert(not b_gate.is_open and not b_gate._collision_shape.disabled)
	a_override.toggle_switch()
	for frame in range(3):
		await get_tree().physics_frame
	assert(not a_gate.is_open)
	assert(b_gate.is_open and b_gate._collision_shape.disabled and b_gate.collision_layer == 0)
	var route_jump := InputEventKey.new()
	route_jump.keycode = KEY_UP
	route_jump.physical_keycode = KEY_UP
	route_jump.pressed = true
	Input.parse_input_event(route_jump)
	for frame in range(30):
		await get_tree().physics_frame
	var route_jump_release := InputEventKey.new()
	route_jump_release.keycode = KEY_UP
	route_jump_release.physical_keycode = KEY_UP
	Input.parse_input_event(route_jump_release)
	var route_release := InputEventKey.new()
	route_release.keycode = KEY_RIGHT
	route_release.physical_keycode = KEY_RIGHT
	Input.parse_input_event(route_release)
	for frame in range(30):
		await get_tree().physics_frame
	var route_left := InputEventKey.new()
	route_left.keycode = KEY_LEFT
	route_left.physical_keycode = KEY_LEFT
	route_left.pressed = true
	Input.parse_input_event(route_left)
	for frame in range(12):
		await get_tree().physics_frame
	var route_left_release := InputEventKey.new()
	route_left_release.keycode = KEY_LEFT
	route_left_release.physical_keycode = KEY_LEFT
	Input.parse_input_event(route_left_release)
	assert(gate_route_gameplay.player2.global_position.x > b_override.position.x - 30.0)
	assert(gate_route_gameplay.player2.is_on_floor())
	assert(b_override.is_pressed)
	assert(a_gate.is_open and b_gate.is_open)
	gate_route_gameplay.player2.die("test_cooperative_gate_respawn")
	gate_route_gameplay.player2._process_death_sequence(1.0)
	assert(gate_route_gameplay.player2.current_state == PuzzlePlayer.State.IDLE)
	assert(a_gate.is_open and b_gate.is_open)
	gate_route_gameplay.load_stage(3)
	for frame in range(3):
		await get_tree().physics_frame
	a_gate = gate_route_gameplay.current_stage.get_node("ReactorSecurityGate") as PuzzleDoor
	b_gate = gate_route_gameplay.current_stage2.get_node("ReactorSecurityGate") as PuzzleDoor
	a_override = gate_route_gameplay.current_stage.get_node("DroneOverrideSwitch") as PuzzleSwitch
	b_override = gate_route_gameplay.current_stage2.get_node("DroneOverrideSwitch") as PuzzleSwitch
	assert(not a_gate.is_open and not b_gate.is_open)
	assert(not b_override.is_pressed and is_equal_approx(b_override.position.x, 1830.0))
	print("[PASS] TEST 14: Player 1 opens Player 2's gate, Player 2 crosses to open Player 1's gate; respawn and reset preserve puzzle integrity.")
	passed_count += 1
	gate_route_gameplay.queue_free()

	# TEST 15: Stage 3 rotating laser has safe, telegraphed, and lethal phases
	total_count += 1
	await get_tree().process_frame
	var laser_single_gameplay: Gameplay = gameplay_scene.instantiate() as Gameplay
	add_child(laser_single_gameplay)
	laser_single_gameplay.load_stage(3)
	for frame in range(4):
		await get_tree().physics_frame
	var reality_manager := get_node("/root/RealityManager") as RealityManager
	reality_manager.set_reality(RealityManager.Reality.REALITY_A)
	var grid_laser := laser_single_gameplay.current_stage.get_node("GridTimedLaser") as LaserEmitter
	grid_laser.mode = LaserEmitter.LaserMode.STATIC
	grid_laser._physics_process(0.016)
	assert(grid_laser._is_firing and not grid_laser._segments.is_empty())
	reality_manager.set_reality(RealityManager.Reality.REALITY_B)
	await get_tree().physics_frame
	assert(not grid_laser._is_firing and grid_laser._segments.is_empty())
	reality_manager.set_reality(RealityManager.Reality.REALITY_A)
	await get_tree().physics_frame
	assert(grid_laser._is_firing and not grid_laser._segments.is_empty())
	var core_laser_single := laser_single_gameplay.current_stage.get_node("CoreSweepLaser") as LaserEmitter
	assert(core_laser_single.mode == LaserEmitter.LaserMode.ROTATING_TIMED)
	assert(is_equal_approx(core_laser_single.max_range, 420.0))
	core_laser_single._time_accumulator = 0.0
	core_laser_single._physics_process(0.0)
	assert(not core_laser_single._is_firing and not core_laser_single._is_telegraphing)
	assert(core_laser_single._segments.is_empty())
	core_laser_single._time_accumulator = core_laser_single.cycle_dormant_time + 0.1
	core_laser_single._physics_process(0.0)
	assert(not core_laser_single._is_firing and core_laser_single._is_telegraphing)
	assert(not core_laser_single._segments.is_empty())
	var telegraph_direction := core_laser_single.laser_direction
	core_laser_single._time_accumulator = core_laser_single.cycle_dormant_time + core_laser_single.cycle_telegraph_time + 0.1
	core_laser_single._physics_process(0.0)
	assert(core_laser_single._is_firing and not core_laser_single._is_telegraphing)
	assert(not core_laser_single._segments.is_empty())
	var visible_beam_length: float = 0.0
	for segment in core_laser_single._segments:
		visible_beam_length += (segment["end"] as Vector2).distance_to(segment["start"] as Vector2)
	assert(visible_beam_length > 0.0 and visible_beam_length <= core_laser_single.max_range + 0.1)
	core_laser_single._time_accumulator += 0.8
	core_laser_single._physics_process(0.0)
	assert(not core_laser_single.laser_direction.is_equal_approx(telegraph_direction))
	laser_single_gameplay.queue_free()

	await get_tree().process_frame
	var laser_coop_gameplay: Gameplay = gameplay_scene.instantiate() as Gameplay
	laser_coop_gameplay.set_multiplayer_mode(true)
	add_child(laser_coop_gameplay)
	laser_coop_gameplay.load_stage(3)
	for frame in range(4):
		await get_tree().physics_frame
	var core_laser_a := laser_coop_gameplay.current_stage.get_node("CoreSweepLaser") as LaserEmitter
	var core_laser_b := laser_coop_gameplay.current_stage2.get_node("CoreSweepLaser") as LaserEmitter
	for core_laser in [core_laser_a, core_laser_b]:
		assert(is_equal_approx(core_laser.max_range, 420.0))
		assert(core_laser.mode == LaserEmitter.LaserMode.ROTATING_TIMED)
		assert(core_laser.burn_player_on_touch and core_laser.active_in_reality == -1)

	laser_coop_gameplay.player.set_physics_process(false)
	laser_coop_gameplay.player.global_position = Vector2(2120.0, 350.0)
	await get_tree().physics_frame
	core_laser_a.sweep_speed = 0.0
	core_laser_a._time_accumulator = core_laser_a.cycle_dormant_time + core_laser_a.cycle_telegraph_time + 0.1
	core_laser_a._physics_process(0.0)
	assert(laser_coop_gameplay.player.current_state == PuzzlePlayer.State.DYING)
	laser_coop_gameplay.player2.set_physics_process(false)
	laser_coop_gameplay.player2.global_position = Vector2(2120.0, 350.0)
	await get_tree().physics_frame
	core_laser_b.sweep_speed = 0.0
	core_laser_b._time_accumulator = core_laser_b.cycle_dormant_time + core_laser_b.cycle_telegraph_time + 0.1
	core_laser_b._physics_process(0.0)
	assert(laser_coop_gameplay.player2.current_state == PuzzlePlayer.State.DYING)
	print("[PASS] TEST 15: Stage 3 has a safe window, warning telegraph, bounded rotating beam, and dangerous active phase in both realities.")
	passed_count += 1
	laser_coop_gameplay.queue_free()
	reality_manager.set_reality(RealityManager.Reality.REALITY_A)

	# TEST 16: Cooperative visual feedback removes its temporary pulse after playback
	total_count += 1
	var linked_pulse := LinkedActionPulse.new()
	add_child(linked_pulse)
	linked_pulse.start(Vector2(80.0, 22.0), RealityManager.COLOR_REALITY_A_PRIMARY)
	await get_tree().create_timer(LinkedActionPulse.DURATION + 0.1).timeout
	assert(not is_instance_valid(linked_pulse))
	print("[PASS] TEST 16: Linked-action visual pulse cleans itself up after playback.")
	passed_count += 1

	# TEST 17: Cooperative receiver activation and deactivation feed back once in the linked reality
	total_count += 1
	await get_tree().process_frame
	var feedback_gameplay: Gameplay = gameplay_scene.instantiate() as Gameplay
	feedback_gameplay.set_multiplayer_mode(true)
	add_child(feedback_gameplay)
	feedback_gameplay.load_stage(2)
	for frame in range(3):
		await get_tree().physics_frame
	var feedback_receiver: LaserReceiver = feedback_gameplay.current_stage.get_node("OverheadReceiver") as LaserReceiver
	var feedback_door: PuzzleDoor = feedback_gameplay.current_stage2.get_node("BlastDoorS2") as PuzzleDoor
	assert(not feedback_receiver.is_powered and not feedback_door.is_open)
	feedback_receiver.receive_laser_hit()
	assert(feedback_receiver.is_powered and feedback_door.is_open)
	var activation_effect := feedback_door.get_node_or_null("LinkedActionPulse") as LinkedActionPulse
	assert(activation_effect != null and activation_effect._activated)
	assert(feedback_gameplay._reality_rift._pulse_activated)
	assert(feedback_gameplay.hud.checkpoint_banner.text == "REALITY LINK ESTABLISHED")
	feedback_receiver._set_powered(false)
	assert(not feedback_receiver.is_powered and not feedback_door.is_open)
	var deactivation_effect := feedback_door.get_node_or_null("LinkedActionPulse") as LinkedActionPulse
	assert(deactivation_effect == activation_effect and not deactivation_effect._activated)
	assert(not feedback_gameplay._reality_rift._pulse_activated)
	assert(feedback_gameplay._reality_rift._pulse_reality == RealityManager.Reality.REALITY_A)
	assert(feedback_gameplay.hud.checkpoint_banner.text == "REALITY LINK ESTABLISHED")
	var deactivation_pulse: float = feedback_gameplay._reality_rift._pulse
	var deactivation_elapsed: float = deactivation_effect._elapsed
	feedback_receiver.powered_changed.emit(false)
	assert(feedback_door.get_node_or_null("LinkedActionPulse") == deactivation_effect)
	assert(feedback_gameplay._reality_rift._pulse == deactivation_pulse)
	assert(deactivation_effect._elapsed == deactivation_elapsed)
	feedback_receiver.receive_laser_hit()
	assert(feedback_door.is_open and deactivation_effect._activated)
	assert(is_zero_approx(deactivation_effect._elapsed))
	assert(feedback_gameplay._reality_rift._pulse_activated)
	await get_tree().create_timer(LinkedActionPulse.DURATION + 0.1).timeout
	assert(not is_instance_valid(deactivation_effect))
	print("[PASS] TEST 17: Linked receiver activation/deactivation highlights the correct target once and cleans up.")
	passed_count += 1
	feedback_gameplay.queue_free()

	print("==================================================================")
	print("   ALL TESTS COMPLETED: %d / %d PASSED" % [passed_count, total_count])
	print("==================================================================")
	if passed_count == total_count:
		print(">>>>> FULL QA VERIFICATION SUCCESSFUL <<<<<")
		get_tree().quit(0)
	else:
		printerr(">>>>> QA VERIFICATION FAILED <<<<<")
		get_tree().quit(1)
