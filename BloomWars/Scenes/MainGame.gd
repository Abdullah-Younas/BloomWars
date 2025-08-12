extends Control

@onready var grid_container_d = $DarkMode/GridContainerD

var rows = 5
var cols = 5
var light_turn := true
var current_player: int = 1
var grid = []

func end_turn():
	current_player = 2 if current_player == 1 else 1
	print("Player", current_player, "turn!")


@onready var D00 = $DarkMode/GridContainerD/Label
@onready var D01 = $DarkMode/GridContainerD/Label2
@onready var D02 = $DarkMode/GridContainerD/Label3
@onready var D03 = $DarkMode/GridContainerD/Label4
@onready var D04 = $DarkMode/GridContainerD/Label5
@onready var D05 = $DarkMode/GridContainerD/Label6
@onready var D06 = $DarkMode/GridContainerD/Label7
@onready var D07 = $DarkMode/GridContainerD/Label8
@onready var D08 = $DarkMode/GridContainerD/Label9
@onready var D09 = $DarkMode/GridContainerD/Label10
@onready var D10 = $DarkMode/GridContainerD/Label11
@onready var D11 = $DarkMode/GridContainerD/Label12
@onready var D12 = $DarkMode/GridContainerD/Label13
@onready var D13 = $DarkMode/GridContainerD/Label14
@onready var D14 = $DarkMode/GridContainerD/Label15
@onready var D15 = $DarkMode/GridContainerD/Label16
@onready var D16 = $DarkMode/GridContainerD/Label17
@onready var D17 = $DarkMode/GridContainerD/Label18
@onready var D18 = $DarkMode/GridContainerD/Label19
@onready var D19 = $DarkMode/GridContainerD/Label20
@onready var D20 = $DarkMode/GridContainerD/Label21
@onready var D21 = $DarkMode/GridContainerD/Label22
@onready var D22 = $DarkMode/GridContainerD/Label23
@onready var D23 = $DarkMode/GridContainerD/Label24
@onready var D24 = $DarkMode/GridContainerD/Label25

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
			cell.set_color(Color.WHITE)
			cell.connect("gui_input", Callable(self, "_on_cell_clicked").bind(r, c))
			grid[r].append(cell)
			i += 1
	_update_mode()
	
func _on_cell_clicked(event: InputEvent, r, c):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var color_to_use = Color.RED if light_turn else Color.YELLOW

		grid[r][c].set_color(color_to_use)
		grid[r][c].click_count += 1

		if grid[r][c].click_count >= 4:
			_explode(r, c)

		switch_turn()


func _explode(r, c):
	var old_color = grid[r][c].get_color()

	grid[r][c].set_color(Color.WHITE)
	grid[r][c].click_count = 0

	for offset in [[0,-1], [0,1], [-1,0], [1,0]]:
		var nr = r + offset[0]
		var nc = c + offset[1]
		if nr >= 0 and nr < rows and nc >= 0 and nc < cols:
			var neighbor = grid[nr][nc]
			if neighbor.get_color() != old_color and neighbor.get_color() != Color.WHITE:
				neighbor.click_count += 1
			else:
				neighbor.click_count = 1

			neighbor.set_color(old_color)


func switch_turn():
	light_turn = !light_turn
	_update_mode()


func _update_mode():
	# Here you can change UI theme depending on player
	if light_turn:
		modulate = Color(1, 1, 1)  # example: white tint for light mode
	else:
		modulate = Color(0.6, 0.6, 0.6)  # example: grey tint for dark mode


func _on_exit_2m_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
