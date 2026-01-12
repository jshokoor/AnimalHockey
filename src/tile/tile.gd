extends Area2D

signal tile_clicked(grid_pos: Vector2i)

var grid_pos : Vector2i

func _ready():
	$Sprite2D.texture = preload("res://icon.svg")


func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		tile_clicked.emit(grid_pos)
		

func set_color(color: Color) -> void:
	$Sprite2D.modulate = color
	print("Setting color on tile:", grid_pos)

func _mouse_entered():
	pass
	#set_color(Color(0.8, 0.8, 0.8)) # light gray hover

func _mouse_exited():
	pass
	#set_color(Color.WHITE)
