extends Control

var ai_enabled := true  # set to false for PvP
@onready var grid_container_d = $BackGround/GridContainerD
@onready var back_ground = $BackGround
@onready var click = $Click
@onready var fail_click = $FailClick
@onready var rich_text_label = $BackGround/ScoreBoard2/RichTextLabel
@onready var game_won_panel = $BackGround/GameWonPanel
@onready var game_won_label = $BackGround/GameWonPanel/GameWonLabel
var move_count := 0
var is_ai_thinking := false
@onready var Flower01 = preload("res://Assets/Textures/Plants/Flower01.png")
@onready var Flower02 = preload("res://Assets/Textures/Plants/Flower02.png")
@onready var Flower03 = preload("res://Assets/Textures/Plants/Flower03.png")
@onready var Flower04 = preload("res://Assets/Textures/Plants/Flower04.png")
@onready var Poison01 = preload("res://Assets/Textures/Plants/Poison000.png")
@onready var Poison02 = preload("res://Assets/Textures/Plants/Poison002.png")
@onready var Poison03 = preload("res://Assets/Textures/Plants/Poison004.png")
@onready var Poison04 = preload("res://Assets/Textures/Plants/Poison006.png")

var light_first_move_made := false
var dark_first_move_made := false
var LightColor = Color(0.996, 0.906, 0.494)
var DarkColor = Color(0.137, 0.239, 0.118)
var rows = 5
var cols = 5
var light_turn := false  # Start with AI turn (dark/poison)
var current_player: int = 1
var grid = []
var pending_explosions: Array = []
var processing_explosions: bool = false
var player_can_move := false  # Track if the player can make a move

# Label refs
@onready var D00 = $BackGround/GridContainerD/Label
@onready var D01 = $BackGround/GridContainerD/Label2
@onready var D02 = $BackGround/GridContainerD/Label3
@onready var D03 = $BackGround/GridContainerD/Label4
@onready var D04 = $BackGround/GridContainerD/Label5
@onready var D05 = $BackGround/GridContainerD/Label6
@onready var D06 = $BackGround/GridContainerD/Label7
@onready var D07 = $BackGround/GridContainerD/Label8
@onready var D08 = $BackGround/GridContainerD/Label9
@onready var D09 = $BackGround/GridContainerD/Label10
@onready var D10 = $BackGround/GridContainerD/Label11
@onready var D11 = $BackGround/GridContainerD/Label12
@onready var D12 = $BackGround/GridContainerD/Label13
@onready var D13 = $BackGround/GridContainerD/Label14
@onready var D14 = $BackGround/GridContainerD/Label15
@onready var D15 = $BackGround/GridContainerD/Label16
@onready var D16 = $BackGround/GridContainerD/Label17
@onready var D17 = $BackGround/GridContainerD/Label18
@onready var D18 = $BackGround/GridContainerD/Label19
@onready var D19 = $BackGround/GridContainerD/Label20
@onready var D20 = $BackGround/GridContainerD/Label21
@onready var D21 = $BackGround/GridContainerD/Label22
@onready var D22 = $BackGround/GridContainerD/Label23
@onready var D23 = $BackGround/GridContainerD/Label24
@onready var D24 = $BackGround/GridContainerD/Label25

func _ready():
	game_won_panel.visible = false
	grid = [
		[D00, D01, D02, D03, D04],
		[D05, D06, D07, D08, D09],
		[D10, D11, D12, D13, D14],
		[D15, D16, D17, D18, D19],
		[D20, D21, D22, D23, D24],
	]
	var i = 0
	for r in range(rows):
		for c in range(cols):
			var cell = grid_container_d.get_child(i)
			cell.click_count = 0
			cell.set_texture(null)
			cell.connect("gui_input", Callable(self, "_on_cell_clicked").bind(r, c))
			grid[r][c] = cell
			i += 1

	# AI makes the very first move
	if ai_enabled:
		player_can_move = false   # player waits
		get_tree().create_timer(1.0).timeout.connect(func():
			ai_make_move()
		)
	else:
		player_can_move = true   # PvP mode, player starts

func _on_cell_clicked(event: InputEvent, r, c):
	if not player_can_move:
		return  # Prevent player from clicking if it's not their turn

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var cell = grid[r][c]
		var cell_texture = cell.get_texture()

		# First move rules
		if cell_texture == null:
			if light_turn and light_first_move_made:
				fail_click.play()
				_shake_cell(cell)
				return
			if not light_turn and dark_first_move_made:
				fail_click.play()
				_shake_cell(cell)
				return
		else:
			# Must click own cell
			if light_turn:
				if cell_texture not in [Flower01, Flower02, Flower03, Flower04]:
					fail_click.play()
					_shake_cell(cell)
					return
			else:
				if cell_texture not in [Poison01, Poison02, Poison03, Poison04]:
					fail_click.play()
					_shake_cell(cell)
					return

		click.play()

		# Mark first move done
		if cell_texture == null:
			if light_turn: light_first_move_made = true
			else: dark_first_move_made = true

		# Growth
		cell.click_count += 1
		if light_turn:
			match cell.click_count:
				1: cell.set_texture(Flower01)
				2: cell.set_texture(Flower02)
				3: cell.set_texture(Flower03)
				4: cell.set_texture(Flower04)
				5:
					_explode(r, c, true, [Flower01, Flower02, Flower03, Flower04])
					switch_turn()
					return
		else:
			match cell.click_count:
				1: cell.set_texture(Poison01)
				2: cell.set_texture(Poison02)
				3: cell.set_texture(Poison03)
				4: cell.set_texture(Poison04)
				5:
					_explode(r, c, false, [Poison01, Poison02, Poison03, Poison04])
					switch_turn()
					return

		switch_turn()

func ai_place(r, c):
	var cell = grid[r][c]
	var cell_texture = cell.get_texture()

	# First move marker
	if cell_texture == null and not dark_first_move_made:
		dark_first_move_made = true

	cell.click_count += 1
	match cell.click_count:
		1: cell.set_texture(Poison01)
		2: cell.set_texture(Poison02)
		3: cell.set_texture(Poison03)
		4: cell.set_texture(Poison04)
		5:
			_explode(r, c, false, [Poison01, Poison02, Poison03, Poison04])
			switch_turn()
			return

	switch_turn()

func _shake_cell(cell):
	var tween = create_tween()
	tween.tween_property(cell, "rotation_degrees", 5, 0.05).as_relative()
	tween.tween_property(cell, "rotation_degrees", -10, 0.05).as_relative()
	tween.tween_property(cell, "rotation_degrees", 5, 0.05).as_relative()

func _finalize_growth(cell, is_flower: bool, textures: Array):
	# Ensure texture matches click_count AFTER tween ends
	var index = clamp(cell.click_count - 1, 0, 3)
	cell.set_texture(textures[index])

func _explode(r, c, is_flower, textures):
	var cell = grid[r][c]
	cell.scale = Vector2(1, 1)
	cell.set_texture(null)
	cell.click_count = 0

	var delay_step = 0.05
	var delay_accum = 0.0

	var direction_offsets = {
		Vector2(0, -1): Vector2(0, -150),
		Vector2(0, 1): Vector2(0, 150),
		Vector2(-1, 0): Vector2(-150, 0),
		Vector2(1, 0): Vector2(150, 0)
	}

	for offset in [[0,-1], [0,1], [-1,0], [1,0]]:
		var nr = r + offset[0]
		var nc = c + offset[1]
		if nr >= 0 and nr < rows and nc >= 0 and nc < cols:
			var neighbor = grid[nr][nc]
			var neighbor_texture = neighbor.get_texture()
			var tween = create_tween()
			tween.tween_interval(delay_accum)
			delay_accum += delay_step

			var dir = Vector2(offset[1], offset[0])
			var pos_offset = direction_offsets.get(-dir, Vector2.ZERO)

			if neighbor_texture == null:
				# Grow new seed
				neighbor.click_count = 1
				neighbor.set_texture(textures[0])  # always stage 1 on spawn
				neighbor.scale = Vector2(1.2, 1.2)
				tween.tween_property(neighbor, "scale", Vector2(1, 1), 0.3)

				# After tween finishes, upgrade texture if needed
				tween.tween_callback(Callable(self, "_finalize_growth")
					.bind(neighbor, is_flower, textures))

			elif (is_flower and neighbor_texture in [Poison01, Poison02, Poison03, Poison04]) \
			   or (not is_flower and neighbor_texture in [Flower01, Flower02, Flower03, Flower04]):

				if neighbor.click_count >= 4:
					neighbor.click_count = 4
					neighbor.set_texture(textures[3])  # stage 4 of attacker type
					await get_tree().create_timer(1.0).timeout
					_explode(nr, nc, is_flower, textures)
				else:
					neighbor.click_count += 1
					neighbor.set_texture(textures[0])  # always start split as stage 1
					neighbor.scale = Vector2(1.2, 1.2)
					tween.tween_property(neighbor, "scale", Vector2(1, 1), 0.3)
					tween.tween_callback(Callable(self, "_finalize_growth")
						.bind(neighbor, is_flower, textures))

			else:
				# Friendly cell
				neighbor.click_count += 1
				if neighbor.click_count >= 5:
					var is_neighbor_flower = neighbor_texture in [Flower01, Flower02, Flower03, Flower04]
					var neighbor_textures = [Flower01, Flower02, Flower03, Flower04] if is_neighbor_flower else [Poison01, Poison02, Poison03, Poison04]
					_explode(nr, nc, is_neighbor_flower, neighbor_textures)
				else:
					neighbor.set_texture(textures[0])  # always stage 1 while moving
					neighbor.scale = Vector2(1.2, 1.2)
					tween.tween_property(neighbor, "scale", Vector2(1, 1), 0.3)
					tween.tween_callback(Callable(self, "_finalize_growth")
						.bind(neighbor, is_flower, textures))

func switch_turn():
	light_turn = !light_turn
	player_can_move = light_turn

	if light_turn:
		rich_text_label.text = "   PLAYER "
	else:
		rich_text_label.text = " COMPUTER"

	# increase moves played
	move_count += 1

	# only start checking after 2 moves
	if move_count >= 2:
		var winner = await check_game_over()
		if winner != "":
			print(winner, " wins!")
			game_won_panel.visible = true
			game_won_label.text = winner + " WINS!!"
			player_can_move = false
			return

	# let AI move if it's AI's turn
	if ai_enabled and not light_turn and not is_ai_thinking:
		is_ai_thinking = true
		await get_tree().create_timer(0.8).timeout
		await ai_make_move()  # Make sure ai_make_move is awaitable
		is_ai_thinking = false

func check_game_over() -> String:
	await get_tree().create_timer(1).timeout				
	var has_flowers := false
	var has_ai_plants := false

	for r in range(rows):
		for c in range(cols):
			var tex = grid[r][c].get_texture()
			if tex == null:
				continue
			if tex in [Flower01, Flower02, Flower03, Flower04]:
				has_flowers = true
			else:
				has_ai_plants = true

	if has_flowers and not has_ai_plants:
		return "Player"
	elif has_ai_plants and not has_flowers:
		return "AI"
	else:
		return ""  # game still going



# -------- AI WITH FORESIGHT --------
func ai_make_move():
	if light_turn:
		return
		
	var best_move = null
	var best_score = -99999

	# First, look for existing poison cells to grow
	for r in range(rows):
		for c in range(cols):
			var cell = grid[r][c]
			if cell.get_texture() in [Poison01, Poison02, Poison03, Poison04]:
				var score = simulate_move(r, c)
				if score > best_score:
					best_score = score
					best_move = Vector2i(r, c)

	# If no poison cells exist (first move), pick a strategic empty cell
	if best_move == null:
		var strategic_positions = [
			Vector2i(2, 2),  # Center
			Vector2i(1, 1), Vector2i(1, 3), Vector2i(3, 1), Vector2i(3, 3),  # Near center
			Vector2i(0, 0), Vector2i(0, 4), Vector2i(4, 0), Vector2i(4, 4)   # Corners
		]
		
		for pos in strategic_positions:
			if grid[pos.x][pos.y].get_texture() == null:
				best_move = pos
				break

	if best_move != null:
		ai_place(best_move.x, best_move.y)

# Simulate move and return score
func simulate_move(r, c):
	var score = 0
	var cell = grid[r][c]
	var before_flower_count = count_flowers()

	# "What if" scenario: +1 click_count, possible explosion
	var fake_count = cell.click_count + 1
	if fake_count >= 5:
		# Big explosion = high score
		score += 5
		# Bonus for hitting flowers
		score += count_adjacent_flowers(r, c) * 3
	else:
		# Smaller growth = lower score
		score += fake_count
		# Bonus if this sets up attack next turn
		if count_adjacent_flowers(r, c) > 0:
			score += 2

	# Extra foresight: fewer flowers after this move = better
	var after_flower_count = max(0, before_flower_count - count_adjacent_flowers(r, c))
	score += (before_flower_count - after_flower_count) * 2

	return score

func count_flowers():
	var count = 0
	for r in range(rows):
		for c in range(cols):
			if grid[r][c].get_texture() in [Flower01, Flower02, Flower03, Flower04]:
				count += 1
	return count

func count_adjacent_flowers(r, c):
	var count = 0
	for offset in [[0,-1],[0,1],[-1,0],[1,0]]:
		var nr = r + offset[0]
		var nc = c + offset[1]
		if nr >= 0 and nr < rows and nc >= 0 and nc < cols:
			if grid[nr][nc].get_texture() in [Flower01, Flower02, Flower03, Flower04]:
				count += 1
	return count

func fake_click(r, c):
	var ev = InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	_on_cell_clicked(ev, r, c)

func _on_exit_2m_pressed():
	click.play()	
	await get_tree().create_timer(.2).timeout	
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_back_pressed():
	click.play()	
	await get_tree().create_timer(.2).timeout	
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
