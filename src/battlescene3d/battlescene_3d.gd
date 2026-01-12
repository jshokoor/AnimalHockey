extends Node3D

# =========================
# Grid Configuration
# =========================
const GRID_SIZE := Vector2i(8, 8)
const CELL_SIZE := 4.0
const GRID_ORIGIN := Vector3(-16, 0, -16)

# =========================
# Interaction Modes
# =========================
enum InteractionMode {
	TACTICAL,
	POV
}

var interaction_mode: InteractionMode = InteractionMode.TACTICAL

@onready var battlecontroller := get_node("battlecontroller")

var last_hovered_grid: Vector2i = Vector2i(-1, -1)

func _ready():
	var wind_dir = $windsystem.wind_direction


	var loot_pos = $windsystem.calculate_fair_loot_point(
		$playership.global_position,
		$enemyship.global_position,
	)

	print("Loot at:", loot_pos)


# =========================
# Input Handling
# =========================
func _unhandled_input(event):
	if interaction_mode != InteractionMode.TACTICAL:
		return

	if event is InputEventMouseMotion:
		_handle_tactical_hover(event)

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_tactical_click(event)

# =========================
# Hover Logic
# =========================
func _handle_tactical_hover(event):
	var result : Dictionary = _raycast_from_mouse(event.position)
	if result == null:
		return

	var grid_pos := world_to_grid(result.position)
	if not _is_grid_in_bounds(grid_pos):
		return

	last_hovered_grid = grid_pos
	$gridhighlight.position = grid_to_world(grid_pos)

# =========================
# Click Logic
# =========================
func _handle_tactical_click(event):
	if not battlecontroller.is_player_turn():
		print("Click ignored: enemy turn")
		return

	if last_hovered_grid == Vector2i(-1, -1):
		return

	print("Grid clicked at:", last_hovered_grid)
	battlecontroller.end_turn()


# =========================
# Raycasting
# =========================
func _raycast_from_mouse(mouse_pos: Vector2):
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return null

	var from := camera.project_ray_origin(mouse_pos)
	var to := from + camera.project_ray_normal(mouse_pos) * 1000.0

	var query := PhysicsRayQueryParameters3D.create(from, to)
	return get_world_3d().direct_space_state.intersect_ray(query)

# =========================
# Grid Utilities
# =========================
func world_to_grid(world_pos: Vector3) -> Vector2i:
	var local := world_pos - GRID_ORIGIN
	return Vector2i(
		floor(local.x / CELL_SIZE),
		floor(local.z / CELL_SIZE)
	)

func grid_to_world(grid_pos: Vector2i) -> Vector3:
	return GRID_ORIGIN + Vector3(
		grid_pos.x * CELL_SIZE + CELL_SIZE * 0.5,
		0.01,
		grid_pos.y * CELL_SIZE + CELL_SIZE * 0.5
	)

func _is_grid_in_bounds(grid_pos: Vector2i) -> bool:
	return (
		grid_pos.x >= 0
		and grid_pos.y >= 0
		and grid_pos.x < GRID_SIZE.x
		and grid_pos.y < GRID_SIZE.y
	)

# =========================
# Mode Control
# =========================
func set_tactical_mode():
	interaction_mode = InteractionMode.TACTICAL
	$gridhighlight.visible = true

func set_pov_mode():
	interaction_mode = InteractionMode.POV
	$gridhighlight.visible = false
