extends Node2D

@export var grid_size := Vector2i(8, 8)
@export var tile_size := 48

@export var tile_scene : PackedScene

var tiles := {}  # Dictionary: Vector2i -> Tile

func _ready():
	create_grid()

func create_grid():
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var grid_pos := Vector2i(x, y)
			
			var tile = tile_scene.instantiate()
			$Tile.add_child(tile)

			tile.grid_pos = grid_pos
			tile.position = grid_to_world(grid_pos)

			tile.tile_clicked.connect(_on_tile_clicked)

			tiles[grid_pos] = tile


func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * tile_size,
		grid_pos.y * tile_size
	)


func _on_tile_clicked(grid_pos: Vector2i) -> void:
	tiles[grid_pos].set_color(Color.RED)
