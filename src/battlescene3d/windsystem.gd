extends Node3D

# =====================
# WIND CONFIG
# =====================
@export var wind_direction: Vector3 = Vector3(1, 0, 0)

# =====================
# LOOT / MOVEMENT CONFIG
# =====================
const SEARCH_DISTANCE: float = 10.0
const SEARCH_STEPS: int = 15
const CELL_SIZE := 4.0


const COST_WITH_WIND: float = 1.0
const COST_CROSS_WIND: float = 2.0
const COST_AGAINST_WIND: float = 3.0


func _ready() -> void:
	_update_wind_visual()


func _process(_delta: float) -> void:
	# Keep it brutally simple and reactive
	_update_wind_visual()


# =====================
# VISUALIZATION
# =====================
func _update_wind_visual() -> void:
	if not has_node("pivot"):
		return

	var pivot: Node3D = $pivot

	var dir := wind_direction
	dir.y = 0.0

	if dir.length() == 0.0:
		return

	dir = dir.normalized()

	# Godot forward is -Z
	var yaw := atan2(dir.x, -dir.z)
	pivot.rotation.y = yaw




# =====================
# PUBLIC API
# =====================
func calculate_fair_loot_point(
	ship_a_pos: Vector3,
	ship_b_pos: Vector3
) -> Vector3:

	var wind := wind_direction.normalized()
	wind.y = 0.0

	var midpoint: Vector3 = (ship_a_pos + ship_b_pos) * 0.5
	var slide_dir: Vector3 = wind.cross(Vector3.UP).normalized()

	var best_point: Vector3 = midpoint
	var smallest_diff: float = 1e20

	for i: int in range(-SEARCH_STEPS, SEARCH_STEPS + 1):
		var t: float = float(i) / float(SEARCH_STEPS)
		var candidate: Vector3 = midpoint + slide_dir * t * SEARCH_DISTANCE

		var cost_a: float = _movement_cost(ship_a_pos, candidate, wind)
		var cost_b: float = _movement_cost(ship_b_pos, candidate, wind)

		var diff: float = abs(cost_a - cost_b)

		if diff < smallest_diff:
			smallest_diff = diff
			best_point = candidate

	return best_point


func get_move_cost(from: Vector3, to: Vector3) -> float:
	return _movement_cost(from, to, wind_direction)


# =====================
# INTERNAL
# =====================
func _movement_cost(from: Vector3, to: Vector3, wind: Vector3) -> float:
	var delta: Vector3 = to - from
	var distance_world: float = delta.length()

	if distance_world == 0.0:
		return 0.0

	# Convert world distance to grid distance
	var distance_grid: float = distance_world / CELL_SIZE

	var dir: Vector3 = delta.normalized()
	var dot: float = dir.dot(-wind)

	var crew_multiplier: float = COST_CROSS_WIND

	if dot > 0.5:
		crew_multiplier = COST_WITH_WIND
	elif dot < -0.5:
		crew_multiplier = COST_AGAINST_WIND

	return distance_grid * crew_multiplier
