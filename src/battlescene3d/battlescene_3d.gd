extends Node3D

# =========================
# Grid Configuration
# =========================
const GRID_SIZE := Vector2i(8, 8)
const CELL_SIZE := 4.0
const GRID_ORIGIN := Vector3(-16, 0, -16)
const MAX_CREW_POINTS := 3.0

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

# =========================
# Ready
# =========================
func _ready():
	var loot_pos: Vector3 = $windsystem.calculate_fair_loot_point(
		$playership.global_position,
		$enemyship.global_position
	)
	print("Loot at:", loot_pos)

# =========================
# Input Handling
# =========================
func _unhandled_input(event):
	if interaction_mode != InteractionMode.TACTICAL:
		return

	if event is InputEventMouseMotion:
		_handle_tactical_hover(event.position)

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_tactical_click()

# =========================
# Hover Logic
# =========================
func _handle_tactical_hover(mouse_pos: Vector2) -> void:
	var result: Dictionary = _raycast_from_mouse(mouse_pos)
	if result.is_empty():
		return

	if not result.has("position"):
		return

	var grid_pos: Vector2i = world_to_grid(result["position"])
	if not _is_grid_in_bounds(grid_pos):
		return

	last_hovered_grid = grid_pos
	$gridhighlight.position = grid_to_world(grid_pos)

	var ship_pos: Vector3 = $playership.global_position
	var target_pos: Vector3 = grid_to_world(grid_pos)

	var crew_cost: float = $windsystem.get_move_cost(ship_pos, target_pos)
	#print("Crew cost:", crew_cost)

# =========================
# Click Logic
# =========================
func _handle_tactical_click() -> void:
	if not battlecontroller.is_player_turn():
		return
	else:
		$playership.crew_points = MAX_CREW_POINTS

	if last_hovered_grid == Vector2i(-1, -1):
		return

	var ship := $playership
	var ship_pos: Vector3 = ship.global_position
	var target_pos: Vector3 = grid_to_world(last_hovered_grid)

	var move_cost: float = $windsystem.get_move_cost(ship_pos, target_pos)

	if move_cost > ship.crew_points:
		print("BLOCKED — cost:", move_cost, " crew:", ship.crew_points)
		return

	# Orient first (already works)
	ship.face_world_position(target_pos)

	# COMMIT
	ship.commit_move(target_pos, move_cost)

	print("MOVED — cost:", move_cost, " remaining:", ship.crew_points)

	battlecontroller.end_turn()




# =========================
# Raycasting (STRICT + SAFE)
# =========================
func _raycast_from_mouse(mouse_pos: Vector2) -> Dictionary:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return {}

	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var to: Vector3 = from + camera.project_ray_normal(mouse_pos) * 1000.0

	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	var result: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)

	return result

# =========================
# Grid Utilities
# =========================
func world_to_grid(world_pos: Vector3) -> Vector2i:
	var local: Vector3 = world_pos - GRID_ORIGIN
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
func set_tactical_mode() -> void:
	interaction_mode = InteractionMode.TACTICAL
	$gridhighlight.visible = true

func set_pov_mode() -> void:
	interaction_mode = InteractionMode.POV
	$gridhighlight.visible = false
