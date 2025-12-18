extends Area2D

signal tile_clicked(grid_pos)

var grid_pos : Vector2i

func _ready():
	$Sprite2D.texture = preload("res://icon.svg")


func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		tile_clicked.emit(grid_pos)

func set_color(color: Color) -> void:
	print("Setting color on tile:", grid_pos)
	$Sprite2D.modulate = color
