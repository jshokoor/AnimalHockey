extends Node3D

@export var facing_direction: Vector3 = Vector3(0, 0, -1)

var crew_points: float = 3.0

func _ready() -> void:
	_update_facing()


func _update_facing() -> void:
	var dir := facing_direction
	dir.y = 0.0

	if dir.length() == 0.0:
		return

	dir = dir.normalized()

	# Godot forward is -Z
	var yaw := atan2(dir.x, -dir.z)
	rotation.y = yaw


func face_world_position(target_pos: Vector3) -> void:
	var direction: Vector3 = target_pos - global_position
	direction.y = 0.0

	if direction.length() == 0.0:
		return

	direction = direction.normalized()

	# Godot forward is +Z for your ship
	var target_yaw: float = atan2(direction.x, direction.z)
	rotation.y = target_yaw + PI


func commit_move(target_pos: Vector3, cost: float) -> void:
	crew_points -= cost
	global_position = target_pos
