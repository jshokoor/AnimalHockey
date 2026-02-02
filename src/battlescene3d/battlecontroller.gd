extends Node

enum TurnOwner {
	PLAYER,
	ENEMY
}

var current_turn: TurnOwner = TurnOwner.PLAYER


@onready var battle_scene := get_parent()
@onready var grid_controller := battle_scene

func _ready():
	start_player_turn()

func start_player_turn():
	current_turn = TurnOwner.PLAYER
	grid_controller.set_tactical_mode()
	print("Player turn started")

func start_enemy_turn():
	current_turn = TurnOwner.ENEMY
	grid_controller.set_tactical_mode()
	print("Enemy turn started")

func end_turn():
	if current_turn == TurnOwner.PLAYER:
		start_enemy_turn()
	else:
		start_player_turn()

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_N:
			print("DEBUG: Forcing next turn")
			end_turn()

func is_player_turn() -> bool:
	return current_turn == TurnOwner.PLAYER
