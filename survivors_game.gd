extends Node2D

@onready var camera_2d: Camera2D = $Player/Camera2D
@onready var ground: TileMapLayer = $Ground
@onready var objects: TileMapLayer = $Objects
@onready var player: CharacterBody2D = $Player


var tile_size = 96
var chunk_size = 32
var view_distance = 16

var noise = FastNoiseLite.new()
var grass_atlas_position = Vector2i(0, 3)

var object_placed_range = Rect2()
var object_tiles_position = {
	"0" = PackedVector2Array(), # trees
	"1" = PackedVector2Array(), # bushes
}

var other_tiles_position = {
	"0": PackedVector2Array()
}

func _ready() -> void:
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = randi()
	noise.frequency = 0.03
	noise.domain_warp_amplitude = 1.0
	
	view_distance = (chunk_size / 2.0) - 1
	load_chunk(player.position.x / tile_size, player.position.y / tile_size)
	
	
func load_chunk(x, y):
	ground.clear()
	objects.clear()
	
	for _x in range(chunk_size):
		for _y in range(chunk_size):
			var noise_value = noise.get_noise_2d(_x+x, _y+y) # values between 0 and 1
			var current_tile_position = Vector2i(_x+x, _y+y)
			var atlas_position = Vector2i()
			
			# place floot tile
			if noise_value < 0.5:
				atlas_position = grass_atlas_position
			else:
				atlas_position = grass_atlas_position # temporary untill other floor tiles exist
			
			if ground.get_cell_source_id(current_tile_position) == -1:
				ground.set_cell(current_tile_position, 0, atlas_position, 0)
			
			# Object Placement
			if randi() % 25 == 0:
				if !object_placed_range.has_point(current_tile_position):
					for i in object_tiles_position:
						match i:
							"0":
								if randi() % 2 == 0 and atlas_position.x == 0:
									object_tiles_position[i].append(current_tile_position)
									break
							"1":
								if atlas_position.x == 0:
									object_tiles_position[i].append(current_tile_position)

	if !object_placed_range.has_point(ground.get_used_rect().position) or !object_placed_range.has_point(ground.get_used_rect().end):
		object_placed_range = object_placed_range.merge(ground.get_used_rect())
		
	for t in object_tiles_position:
		match t:
			"0":
				for tp in range(object_tiles_position[t].size()):
					if ground.get_cell_source_id(Vector2i(object_tiles_position[t][tp].x, object_tiles_position[t][tp].y)) != -1 or ground.get_cell_source_id(Vector2i(object_tiles_position[t][tp].x, object_tiles_position[t][tp].y+1)) == -1:
						draw_tree(object_tiles_position[t][tp].x, object_tiles_position[t][tp].y)
			"1":
				for tp in range(object_tiles_position[t].size()):
					if ground.get_cell_source_id(Vector2i(object_tiles_position[t][tp].x, object_tiles_position[t][tp].y)) != -1:
						draw_bush(object_tiles_position[t][tp].x, object_tiles_position[t][tp].y)
	
	for ot in other_tiles_position:
		match ot:
			"0":
				for op in range(other_tiles_position[ot].size()):
					if ground.get_cell_source_id(other_tiles_position[ot][op]) != -1:
						ground.set_cell(other_tiles_position[ot][op], 2, Vector2i(3, 2), 0)

func _physics_process(_delta: float) -> void:
	
	# Chunk loading / unloading
	var world_size = ground.get_used_rect() as Rect2i
	var world_size_start = world_size.position
	var world_size_end = world_size.end
	var player_position_negitive = ($Player.position  / tile_size) - Vector2(view_distance, view_distance)
	var player_position_positive = ($Player.position  / tile_size) + Vector2(view_distance, view_distance)
	
	# left / right generation
	if player_position_positive.x > world_size_end.x:
		load_chunk(world_size_start.x + 1, world_size_start.y)
	elif player_position_negitive.x < world_size_start.x:
		load_chunk(world_size_start.x - 1, world_size_start.y)
	# up / down generation
	if player_position_positive.y > world_size_end.y:
		load_chunk(world_size_start.x, world_size_start.y + 1)
	elif player_position_negitive.y < world_size_start.y:
		load_chunk(world_size_start.x, world_size_start.y - 1)

func _input(event: InputEvent) -> void:
	# Mouse wheel zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_2d.zoom += Vector2(0.05, 0.05)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_2d.zoom -= Vector2(0.05, 0.05)

func draw_tree(x, y):
	const TREE = preload("res://pine_tree.tscn")
	
	var new_tree = TREE.instantiate()
	if ground.get_cell_source_id(Vector2i(x, y)) != -1:
		#objects.set_cell(Vector2i(x, y-1), 0, Vector2i(0, 0), 0)
		new_tree.global_position = Vector2i(x*tile_size, y*tile_size)
		add_child(new_tree)
		
	#if ground.get_cell_source_id(Vector2i(x, y)) != -1:
		#objects.set_cell(Vector2i(x, y), 0, Vector2i(0, 1), 0)

	#if ground.get_cell_atlas_coords(Vector2i(x, y-2)) == Vector2i(0, 0):
		#objects.erase_cell(Vector2i(x, y-2))

func draw_bush(x, y):
	if ground.get_cell_source_id(Vector2i(x, y)) != -1:
		objects.set_cell(Vector2i(x, y), 0, Vector2i(0, 2), 0)

func spawn_mob():
	var new_mob = preload("res://mob.tscn").instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)
	
func _on_timer_timeout() -> void:
	spawn_mob()

func _on_player_health_depleted() -> void:
	%GameOver.visible = true
	get_tree().paused = true
