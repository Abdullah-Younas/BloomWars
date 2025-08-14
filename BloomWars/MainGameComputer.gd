extends Control

var ai_enabled := true  # set to false for PvP
@onready var grid_container_d = $BackGround/GridContainerD
@onready var back_ground = $BackGround
@onready var click = $Click
@onready var fail_click = $FailClick
@onready var rich_text_label = $BackGround/ScoreBoard/RichTextLabel

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
var light_turn := true
var current_player: int = 1
var grid = []
var pending_explosions: Array = []
var processing_explosions: bool = false

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

func _on_cell_clicked(event: InputEvent, r, c):
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

func _shake_cell(cell):
	var tween = create_tween()
	tween.tween_property(cell, "position:x", cell.position.x + 5, 0.05)
	tween.tween_property(cell, "position:x", cell.position.x - 5, 0.05)
	tween.tween_property(cell, "position:x", cell.position.x, 0.05)

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
				neighbor.set_texture(textures[0])
				neighbor.position += pos_offset
				tween.tween_property(neighbor, "position", neighbor.position - pos_offset, 0.3)

			elif (is_flower and neighbor_texture in [Poison01, Poison02, Poison03, Poison04]) \
			   or (not is_flower and neighbor_texture in [Flower01, Flower02, Flower03, Flower04]):

				# Enemy cell takeover
				if neighbor.click_count >= 4:
					# Convert to our type at level 4
					neighbor.click_count = 4
					neighbor.set_texture(textures[3])  # stage 4 of the attacker type
					
					# Wait then explode
					await get_tree().create_timer(1.0).timeout
					_explode(nr, nc, is_flower, textures)
				else:
					neighbor.click_count += 1
					neighbor.set_texture(textures[min(neighbor.click_count - 1, 3)])
					neighbor.position += pos_offset
					tween.tween_property(neighbor, "position", neighbor.position - pos_offset, 0.3)

			else:
				# Friendly cell
				neighbor.click_count += 1
				if neighbor.click_count >= 5:
					var is_neighbor_flower = neighbor_texture in [Flower01, Flower02, Flower03, Flower04]
					var neighbor_textures = [Flower01, Flower02, Flower03, Flower04] if is_neighbor_flower else [Poison01, Poison02, Poison03, Poison04]
					_explode(nr, nc, is_neighbor_flower, neighbor_textures)
				else:
					neighbor.set_texture(textures[min(neighbor.click_count - 1, 3)])
					neighbor.position += pos_offset
					tween.tween_property(neighbor, "position", neighbor.position - pos_offset, 0.3)


func switch_turn():
	light_turn = !light_turn
	if ai_enabled and not light_turn:
		if check_game_over():
			print("AI wins!")
			return
		get_tree().create_timer(0.8).timeout.connect(func ():
			ai_make_move()
		)

func check_game_over():
	for r in range(rows):
		for c in range(cols):
			if grid[r][c].get_texture() in [Flower01, Flower02, Flower03, Flower04]:
				return false
	return true

# -------- AI WITH FORESIGHT --------
func ai_make_move():
	var best_move = null
	var best_score = -99999

	for r in range(rows):
		for c in range(cols):
			var cell = grid[r][c]
			if cell.get_texture() in [Poison01, Poison02, Poison03, Poison04]:
				# Simulate this move
				var score = simulate_move(r, c)
				if score > best_score:
					best_score = score
					best_move = Vector2i(r, c)

	if best_move != null:
		fake_click(best_move.x, best_move.y)

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
