@tool
extends Node3D

@onready var track_path: Path3D = $"../TrackPath"
@onready var track_floor: MeshInstance3D = $TrackFloor
@onready var track_wall: MeshInstance3D = $TrackWall

@export var reload := false:
	set(new_reload):
		reload = false
		regenerate_meshes()

@export_range(10.0, 100.0) var resolution := 1.0:
	set(new_resolution):
		resolution = new_resolution
		regenerate_meshes()
		
@export_range(10.0, 100.0) var width := 10.0:
	set(new_width):
		width = new_width
		regenerate_meshes()
		
@export_range(1.0, 100.0) var height := 0.5:
	set(new_height):
		height = new_height
		regenerate_meshes()

var floor_mesh: ArrayMesh
var wall_mesh: ArrayMesh

func regenerate_meshes() -> void:
	if not is_node_ready() or track_path == null:
		return
	if !floor_mesh:
		floor_mesh = ArrayMesh.new()
		track_floor.mesh = floor_mesh
	floor_mesh.clear_surfaces()
	floor_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, create_floor())
	if !wall_mesh:
		wall_mesh = ArrayMesh.new()
		track_wall.mesh = wall_mesh
	wall_mesh.clear_surfaces()
	wall_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, create_wall())
	
	
func create_floor() -> Array:
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	var positions := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()

	var points = sample_points()
	for i in range(points.size()):
		var point: Transform3D = points[i]
		positions.push_back(point.origin + point.basis.x * -width*0.5)
		normals.push_back(point.basis.y)
		uvs.push_back(Vector2(0, i))
		positions.push_back(point.origin + point.basis.x * width*0.5)
		uvs.push_back(Vector2(1, i))
		normals.push_back(point.basis.y)
		
	var offset := 0
	for i in range(points.size() - 1):
		var new_indices: PackedInt32Array = [
			1 + offset, 0 + offset, 2 + offset,
			1 + offset, 2 + offset, 3 + offset
		]
		offset += 2
		indices.append_array(new_indices)

	surface_array[Mesh.ARRAY_VERTEX] = positions
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_INDEX] = indices
	return surface_array
	
func create_wall() -> Array:
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	var positions := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()

	var points = sample_points()
	
	# left wall
	for i in range(points.size()):
		var point: Transform3D = points[i]
		positions.push_back(point.origin + point.basis.x * -width*0.5)
		normals.push_back(point.basis.x)
		uvs.push_back(Vector2(0, i))
		positions.push_back(point.origin + point.basis.x * -width*0.5 + point.basis.y * height)
		normals.push_back(point.basis.x)
		uvs.push_back(Vector2(height/resolution, i))
		
	#right wall
	for i in range(points.size()):
		var point: Transform3D = points[i]
		positions.push_back(point.origin + point.basis.x * width*0.5)
		normals.push_back(-point.basis.x)
		uvs.push_back(Vector2(0, i))
		positions.push_back(point.origin + point.basis.x * width*0.5 + point.basis.y * height)
		normals.push_back(-point.basis.x)
		uvs.push_back(Vector2(height/resolution, i))
		
	var offset := 0
	for i in range(points.size() - 1):
		var new_indices: PackedInt32Array = [
			 0 + offset, 1 + offset, 2 + offset,
			1 + offset, 3 + offset, 2 + offset
		]
		offset += 2
		indices.append_array(new_indices)
	
	offset += 2
	for i in range(points.size() - 1):
		var new_indices: PackedInt32Array = [
			 0 + offset, 2 + offset, 1 + offset,
			1 + offset, 2 + offset, 3 + offset
		]
		offset += 2
		indices.append_array(new_indices)

	surface_array[Mesh.ARRAY_VERTEX] = positions
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	return surface_array;
	
func sample_points() -> Array:
	track_path.curve.bake_interval = resolution
	track_path.curve.up_vector_enabled = true
	var points = []
	var distance = track_path.curve.get_baked_length()
	var offset: float = 0.0
	while offset <= distance:
		var point: Transform3D = track_path.curve.sample_baked_with_rotation(offset, false, true)
		points.push_back(point)
		offset += track_path.curve.bake_interval
	points.push_back(track_path.curve.sample_baked_with_rotation(distance, false, true))
	return points
