@tool
extends Node2D

## Script to render specific child nodes (usually TileMapLayers) to a PNG image using SubViewport.
## Attach this to the parent Node2D containing the TileMapLayer nodes.

## The file path where the PNG image will be saved.
@export var output_path: String = "user://generated_map.png"
## Optional padding (in pixels) around the calculated bounds.
@export var padding: int = 0
## If true, only renders children of type TileMapLayer.
@export var render_tilemaps_only: bool = false
## Check this box in the editor to trigger the image generation.
@export var generate_image: bool = false:
	set(value):
		if value:
			print("Generation triggered...")
			call_deferred("_generate_png")
		# Don't store true, act like a button

# --- Main Generation Function ---
func _generate_png():
	print("Starting PNG generation for: ", self.name)

	# --- Pre-checks ---
	if not ClassDB.can_instantiate("SubViewport"):
		printerr("Error: Cannot instantiate SubViewport. Check Godot version/installation.")
		_cleanup_trigger()
		return

	var nodes_to_render: Array[Node] = []
	var original_parents: Dictionary = {}
	var original_transforms: Dictionary = {}
	var original_z_indices: Dictionary = {}
	var original_global_positions: Dictionary = {} # Store original global position for setting local pos later

	# --- 1. Identify Nodes to Render and Calculate Bounds ---
	var total_bounds: Rect2 = Rect2()
	var first_node = true

	for child in get_children():
		var should_render = false
		var is_tilemap_layer = false

		# Determine if child should be rendered based on type and export setting
		if render_tilemaps_only:
			if child is TileMapLayer:
				should_render = true
				is_tilemap_layer = true
		else:
			if child is CanvasItem and not child is SubViewportContainer and not child is SubViewport:
				# Exclude non-visual nodes like AudioStreamPlayer2D
				if child is AudioStreamPlayer2D:
					print(".........Skipping '%s' (type: %s) as it has no visual content." % [child.name, child.get_class()])
					continue
				should_render = true
				if child is TileMapLayer:
					is_tilemap_layer = true
			if child is StaticBody2D: # Always exclude unless it has renderable children
				should_render = false

		if should_render:
			var canvas_item = child as CanvasItem
			# Check validity and visibility
			if canvas_item and canvas_item.is_visible_in_tree():
				var item_rect_global: Rect2

				# Calculate bounds differently for TileMapLayers vs other CanvasItems
				if is_tilemap_layer:
					var layer = child as TileMapLayer
					if not layer.tile_set:
						printerr(".........Skipping TileMapLayer '%s' because it has no TileSet assigned." % layer.name)
						continue

					var used_rect_tiles: Rect2i = layer.get_used_rect()
					if used_rect_tiles.size.x <= 0 or used_rect_tiles.size.y <= 0:
						continue

					var tile_size_i: Vector2i = layer.tile_set.tile_size
					var tile_size_f: Vector2 = Vector2(tile_size_i)
					var local_pixel_pos: Vector2 = Vector2(used_rect_tiles.position) * tile_size_f
					var pixel_size: Vector2 = Vector2(used_rect_tiles.size) * tile_size_f

					var item_rect_local_pixels: Rect2 = Rect2(local_pixel_pos, pixel_size)
					item_rect_global = layer.global_transform * item_rect_local_pixels

				else: # Generic CanvasItem path, including Node2D
					if canvas_item is Sprite2D or canvas_item is TextureRect or canvas_item.has_method("get_item_rect"):
						if canvas_item.has_method("get_item_rect"):
							var item_rect_local = canvas_item.get_item_rect()
							item_rect_global = canvas_item.global_transform * item_rect_local
						else:
							# Fallback for Sprite2D/TextureRect without get_item_rect
							var size = Vector2(1, 1)
							if canvas_item is Sprite2D and canvas_item.texture:
								size = canvas_item.texture.get_size()
							elif canvas_item is TextureRect and canvas_item.texture:
								size = canvas_item.texture.get_size()
							item_rect_global = Rect2(canvas_item.global_position, size)
					else:
						# Handle Node2D or other CanvasItems without get_item_rect
						item_rect_global = _calculate_node2d_bounds(canvas_item)
						if item_rect_global.size.x <= 0 or item_rect_global.size.y <= 0:
							print(".........Skipping CanvasItem '%s' (type: %s) as it has no valid bounds." % [canvas_item.name, canvas_item.get_class()])
							continue
						print(".........Calculated bounds for '%s' (type: %s): %s" % [canvas_item.name, canvas_item.get_class(), item_rect_global])

				# Merge Bounds (only if valid global rect calculated)
				if item_rect_global.size.x > 0 and item_rect_global.size.y > 0:
					original_global_positions[canvas_item] = canvas_item.global_position
					nodes_to_render.append(canvas_item)
					if first_node:
						total_bounds = item_rect_global
						first_node = false
					else:
						total_bounds = total_bounds.merge(item_rect_global)

	# --- Check if any nodes were selected ---
	if nodes_to_render.is_empty():
		printerr("No suitable, visible child nodes (with valid bounds) found to render.")
		_cleanup_trigger()
		return

	# --- Process Bounds ---
	total_bounds.position -= Vector2(padding, padding)
	total_bounds.size += Vector2(padding, padding) * 2.0
	total_bounds.size.x = max(1.0, total_bounds.size.x)
	total_bounds.size.y = max(1.0, total_bounds.size.y)

	print("Calculated Global Bounds: %s" % total_bounds)
	var image_size = Vector2i(ceil(total_bounds.size.x), ceil(total_bounds.size.y))

	# Size checks
	if image_size.x <= 0 or image_size.y <= 0:
		printerr("Error: Calculated image size (%s) is zero or negative. Aborting." % image_size)
		_cleanup_trigger()
		return

	print("Target Image Size: %s" % image_size)

	# --- 2. Create SubViewport ---
	var sub_viewport = SubViewport.new()
	sub_viewport.size = image_size
	sub_viewport.transparent_bg = true
	sub_viewport.handle_input_locally = false
	sub_viewport.render_target_update_mode = SubViewport.UpdateMode.UPDATE_ONCE
	sub_viewport.render_target_clear_mode = SubViewport.ClearMode.CLEAR_MODE_NEVER
	sub_viewport.name = "MapRenderSubViewport_Temporary"
	var bounds_origin = total_bounds.position

	# --- 3. Temporarily Move Nodes to SubViewport ---
	print("...Moving %d nodes to SubViewport" % nodes_to_render.size())
	for node in nodes_to_render:
		var parent = node.get_parent()
		if parent and is_instance_valid(parent):
			var original_gpos = original_global_positions.get(node, Vector2.ZERO)
			var canvas_item = node as CanvasItem
			original_parents[node] = parent
			original_transforms[node] = node.transform
			if canvas_item:
				original_z_indices[node] = canvas_item.z_index

			parent.remove_child(node)
			sub_viewport.add_child(node)

			var target_local_pos = original_gpos - bounds_origin
			node.position = target_local_pos

			print("......Node: %s, Original Global: %s, Bounds Origin: %s, Target Local Pos: %s" % [node.name, original_gpos, bounds_origin, target_local_pos])

			if canvas_item and node in original_z_indices:
				canvas_item.z_index = original_z_indices[node]
		else:
			printerr("Node ", node.name, " had no valid parent, skipping move.")

	# --- 4. Add SubViewport to Scene Tree & Render ---
	add_child(sub_viewport)

	if Engine.is_editor_hint():
		print("Waiting for rendering server (will wait multiple frames)...")
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		print("Rendering should be complete.")
	else:
		await get_tree().process_frame

	# --- 5. Get Texture and Image ---
	print("...Attempting to get texture.")
	var texture: ViewportTexture = sub_viewport.get_texture()
	if not texture:
		printerr("Failed to get texture from SubViewport.")
		_cleanup(sub_viewport, nodes_to_render, original_parents, original_transforms, original_z_indices)
		return

	if Engine.is_editor_hint(): await get_tree().create_timer(0.05).timeout
	else: await get_tree().create_timer(0.01).timeout

	print("...Attempting to get image from texture.")
	var image: Image = texture.get_image()

	if not image or image.is_empty():
		print("Image data not ready, waiting one more frame...")
		if Engine.is_editor_hint(): await RenderingServer.frame_post_draw
		else: await get_tree().process_frame
		image = texture.get_image()
		if not image or image.is_empty():
			printerr("Failed to get valid image data from texture even after delay.")
			_cleanup(sub_viewport, nodes_to_render, original_parents, original_transforms, original_z_indices)
			return

	print("Image data retrieved successfully. Format: ", image.get_format())

	# --- 6. Save Image ---
	if output_path.begins_with("user://"):
		var dir_path = output_path.get_base_dir()
		var dir = DirAccess.open(dir_path)
		if not dir:
			var err_dir = DirAccess.make_dir_recursive_absolute(dir_path)
			if err_dir != OK:
				printerr("Failed to create directory %s. Error: %s" % [dir_path, error_string(err_dir)])
				_cleanup(sub_viewport, nodes_to_render, original_parents, original_transforms, original_z_indices)
				return

	var err_save = image.save_png(output_path)

	if err_save == OK:
		print("Successfully saved image to: ", ProjectSettings.globalize_path(output_path))
		if output_path.begins_with("res://"):
			if Engine.is_editor_hint():
				var editor_fs = EditorInterface.get_resource_filesystem()
				if editor_fs:
					print("Scanning editor filesystem...")
					await get_tree().create_timer(0.1).timeout
					editor_fs.scan()
				else:
					print("Could not get EditorResourceFilesystem to force scan.")
		elif output_path.begins_with("user://"):
			print("Image saved to user:// directory. Access via Project > Open User Data Folder.")
	else:
		printerr("Error saving PNG image: %s (Path: %s)" % [error_string(err_save), output_path])

	# --- 7. Cleanup ---
	_cleanup(sub_viewport, nodes_to_render, original_parents, original_transforms, original_z_indices)

	print("PNG generation finished.")

# --- Helper Function to Calculate Node2D Bounds ---
func _calculate_node2d_bounds(node: CanvasItem) -> Rect2:
	var bounds: Rect2 = Rect2()
	var first_child = true

	# Traverse children to find renderable CanvasItems
	for child in node.get_children():
		if child is CanvasItem and child.is_visible_in_tree() and not child is SubViewportContainer and not child is SubViewport:
			var child_rect: Rect2
			if child is TileMapLayer:
				var layer = child as TileMapLayer
				if layer.tile_set:
					var used_rect_tiles: Rect2i = layer.get_used_rect()
					if used_rect_tiles.size.x > 0 and used_rect_tiles.size.y > 0:
						var tile_size_i: Vector2i = layer.tile_set.tile_size
						var tile_size_f: Vector2 = Vector2(tile_size_i)
						var local_pixel_pos: Vector2 = Vector2(used_rect_tiles.position) * tile_size_f
						var pixel_size: Vector2 = Vector2(used_rect_tiles.size) * tile_size_f
						var item_rect_local_pixels: Rect2 = Rect2(local_pixel_pos, pixel_size)
						child_rect = layer.global_transform * item_rect_local_pixels
			elif child is Sprite2D or child is TextureRect:
				var size = Vector2(1, 1)
				if child is Sprite2D and child.texture:
					size = child.texture.get_size()
				elif child is TextureRect and child.texture:
					size = child.texture.get_size()
				child_rect = Rect2(child.global_position, size)
			elif child.has_method("get_item_rect"):
				var item_rect_local = child.get_item_rect()
				child_rect = child.global_transform * item_rect_local
			else:
				# Recursively calculate bounds for nested Node2D or similar
				child_rect = _calculate_node2d_bounds(child as CanvasItem)
				if child_rect.size.x <= 0 or child_rect.size.y <= 0:
					continue

			if child_rect.size.x > 0 and child_rect.size.y > 0:
				if first_child:
					bounds = child_rect
					first_child = false
				else:
					bounds = bounds.merge(child_rect)

	# If no renderable children, use a default small bounds
	if first_child:
		print(".........No renderable children found for '%s' (type: %s). Using default bounds." % [node.name, node.get_class()])
		return Rect2(node.global_position - Vector2(0.5, 0.5), Vector2(1, 1))

	return bounds

# --- Cleanup Function ---
func _cleanup(sub_viewport: SubViewport, nodes: Array[Node], parents: Dictionary, transforms: Dictionary, z_indices: Dictionary):
	print("Cleaning up...")
	for node in nodes:
		if node not in parents: continue
		if not is_instance_valid(node): continue

		if is_instance_valid(sub_viewport) and node.get_parent() == sub_viewport:
			sub_viewport.remove_child(node)

		var original_parent = parents.get(node)
		if is_instance_valid(original_parent):
			if not node.is_queued_for_deletion():
				node.transform = transforms.get(node, Transform2D())
				if node is CanvasItem and node in z_indices:
					(node as CanvasItem).z_index = z_indices[node]
				if node.get_parent() != original_parent:
					original_parent.add_child(node)
			else:
				print("Warning: Node ", node.name, " was queued for deletion.")
		else:
			print("Warning: Original parent for ", node.name, " is no longer valid.")
			if not node.is_queued_for_deletion():
				print("Orphaned node ", node.name, " will be freed.")
				node.queue_free()

	if is_instance_valid(sub_viewport):
		if sub_viewport.get_parent() == self:
			remove_child(sub_viewport)
		sub_viewport.queue_free()

	_cleanup_trigger()

# --- Inspector Trigger Reset Function ---
func _cleanup_trigger():
	if Engine.is_editor_hint():
		if generate_image == true:
			generate_image = false
			notify_property_list_changed()
	else:
		generate_image = false
