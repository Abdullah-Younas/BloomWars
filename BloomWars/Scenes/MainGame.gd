extends Control

@onready var light_mode = $LightMode
@onready var dark_mode = $DarkMode

var light_turn := true # start with light mode's turn

func _ready():
	_update_mode()

func switch_turn():
	light_turn = !light_turn
	_update_mode()

func _update_mode():
	light_mode.visible = light_turn
	dark_mode.visible =  !light_turn

func _on_exit_2m_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _input(event):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		switch_turn()
