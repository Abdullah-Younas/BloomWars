extends Control

@onready var grid_container_d = $BackGround/GridContainerD
@onready var back_ground = $BackGround

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
var bg_color: Color = Color(1,1,1,1) # white
var rows = 5
var cols = 5
var light_turn := true
var current_player: int = 1
var grid = []

func end_turn():
	current_player = 2 if current_player == 1 else 1
	print("Player", current_player, "turn!")

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
	# Fill grid with label references
	grid = [
		[D00, D01, D02, D03, D04],
		[D05, D06, D07, D08, D09],
		[D10, D11, D12, D13, D14],
		[D15, D16, D17, D18, D19],
		[D20, D21, D22, D23, D24],
	]
	var i = 0
	for r in range(rows):
		grid.append([])
		for c in range(cols):
			var cell = grid_container_d.get_child(i)
			cell.click_count = 0
			cell.set_texture(null) # Start with no texture
			cell.connect("gui_input", Callable(self, "_on_cell_clicked").bind(r, c))
			grid[r].append(cell)
			i += 1
	
func _on_cell_clicked(event: InputEvent, r, c):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var cell = grid[r][c]
		var cell_texture = cell.get_texture()
		
		# First move validation
		if cell_texture == null:
			if light_turn and light_first_move_made: return
			if not light_turn and dark_first_move_made: return
		else:
			# Ownership validation
			if light_turn:
				if cell_texture not in [Flower01, Flower02, Flower03, Flower04]: return
			else:
				if cell_texture not in [Poison01, Poison02, Poison03, Poison04]: return
		
		# Mark first move
		if cell_texture == null:
			if light_turn: light_first_move_made = true
			else: dark_first_move_made = true
		
		# Growth logic
		cell.click_count += 1
		
		if cell.click_count == 4: # Mature stage - split immediately
			_explode(r, c)
		else:
			# Update to next growth stage
			if light_turn:
				match cell.click_count:
					1: cell.set_texture(Flower01)
					2: cell.set_texture(Flower02)
					3: cell.set_texture(Flower03)
			else:
				match cell.click_count:
					1: cell.set_texture(Poison01)
					2: cell.set_texture(Poison02)
					3: cell.set_texture(Poison03)

		switch_turn()

func _explode(r, c):
	var cell = grid[r][c]
	var is_flower = cell.get_texture() in [Flower01, Flower02, Flower03, Flower04]
	var textures = [Flower01, Flower02, Flower03, Flower04] if is_flower else [Poison01, Poison02, Poison03, Poison04]
	
	# Reset exploded cell
	cell.set_texture(null)
	cell.click_count = 0
	
	# Affect neighbors
	for offset in [[0,-1], [0,1], [-1,0], [1,0]]:
		var nr = r + offset[0]
		var nc = c + offset[1]
		if nr >= 0 and nr < rows and nc >= 0 and nc < cols:
			var neighbor = grid[nr][nc]
			var neighbor_texture = neighbor.get_texture()
			
			if neighbor_texture == null:
				# Empty becomes stage 1
				neighbor.click_count = 1
				neighbor.set_texture(textures[0])
			elif (is_flower and neighbor_texture in [Poison01, Poison02, Poison03]) or \
				 (not is_flower and neighbor_texture in [Flower01, Flower02, Flower03]):
				# Convert opponent's plant
				neighbor.click_count = min(neighbor.click_count + 1, 3)
				neighbor.set_texture(textures[neighbor.click_count - 1])
			else:
				# Grow your own plant
				neighbor.click_count = min(neighbor.click_count + 1, 3)
				if neighbor.click_count == 4:
					# New plants can't split immediately
					neighbor.click_count = 3
				neighbor.set_texture(textures[neighbor.click_count - 1])
func switch_turn():
	light_turn = !light_turn

func _on_exit_2m_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
