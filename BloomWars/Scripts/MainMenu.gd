extends Control

@onready var main_btns = $MainBtns
@onready var settings_panel = $SettingsPanel
@onready var music = $Music
@onready var game_mode_panel = $GameModePanel

# Called when the node enters the scene tree for the first time.
func _ready():
	game_mode_panel.visible = false
	settings_panel.visible = false
	main_btns.visible = true

func _on_start_pressed():
	main_btns.visible = false
	game_mode_panel.visible = true

func _on_settings_pressed():
	main_btns.visible = false
	settings_panel.visible = true

func _on_exit_pressed():
	get_tree().quit()

func _on_back_pressed():
	main_btns.visible = true
	settings_panel.visible = false

func _on_audio_stream_player_2d_finished():
	music.play()

func _on_pvp_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainGame.tscn")

func _on_pvpc_pressed():
	get_tree().change_scene_to_file("res://MainGameComputer.tscn")

func _on_back_mode_pressed():
	main_btns.visible = true
	game_mode_panel.visible = false
