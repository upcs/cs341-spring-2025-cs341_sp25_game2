@tool
extends Node2D

## Script to render specific child nodes (usually TileMapLayers) to a PNG image using SubViewport.
## Attach this to the parent Node2D containing the TileMapLayer nodes.

## The file path where the PNG image will be saved.
@export var output_path: String = "user://generated_map.png"
## Optional padding (in pixels) around the calculated bounds.
@export var padding: int = 0
## If true, only renders children of type TileMapLayer.
@export var render_tilemaps_only: bool = true
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
				should_render = true
				if child is TileMapLayer: # Still need to identify for calculation
					is_tilemap_layer = true
			if child is StaticBody2D: # Always exclude
				should_render = false

		if should_render:
			var canvas_item = child as CanvasItem
			# Check validity and visibility
			if canvas_item and canvas_item.is_visible_in_tree():
				var item_rect_global : Rect2

				# Calculate bounds differently for TileMapLayers vs other CanvasItems
				if is_tilemap_layer:
					var layer = child as TileMapLayer
					if not layer.tile_set:
						printerr(".........Skipping TileMapLayer '%s' because it has no TileSet assigned." % layer.name)
						continue

					var used_rect_tiles : Rect2i = layer.get_used_rect()
					if used_rect_tiles.size.x <= 0 or used_rect_tiles.size.y <= 0:
						continue

					# Convert types before multiplication
					var tile_size_i : Vector2i = layer.tile_set.tile_size
					var tile_size_f : Vector2 = Vector2(tile_size_i)
					var local_pixel_pos : Vector2 = Vector2(used_rect_tiles.position) * tile_size_f
					var pixel_size : Vector2 = Vector2(used_rect_tiles.size) * tile_size_f

					var item_rect_local_pixels : Rect2 = Rect2(local_pixel_pos, pixel_size)
					item_rect_global = layer.global_transform * item_rect_local_pixels

				else: # Generic CanvasItem path
					if canvas_item.has_method("get_item_rect"):
						var item_rect_local = canvas_item.get_item_rect()
						item_rect_global = canvas_item.global_transform * item_rect_local
					else:
						printerr(".........Skipping CanvasItem '%s' as it does not have 'get_item_rect'." % canvas_item.name)
						continue

				# Merge Bounds (only if valid global rect calculated)
				if item_rect_global.size.x > 0 and item_rect_global.size.y > 0:
					# Store original global position BEFORE adding to list/bounds merge
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
	if image_size.x > 8192 or image_size.y > 8192:
		printerr("Error: Calculated image size (%s) is very large (>8192px). Aborting." % image_size)
		_cleanup_trigger()
		return
	if image_size.x <= 0 or image_size.y <= 0:
		printerr("Error: Calculated image size (%s) is zero or negative. Aborting." % image_size)
		_cleanup_trigger()
		return

	print("Target Image Size: %s" % image_size)

	# --- 2. Create SubViewport ---
	var sub_viewport = SubViewport.new()
	sub_viewport.size = image_size
	sub_viewport.transparent_bg = true # Keep transparency attempt
	sub_viewport.handle_input_locally = false
	sub_viewport.render_target_update_mode = SubViewport.UpdateMode.UPDATE_ONCE
	# !!! CHANGE 1: Set Clear Mode !!!
	sub_viewport.render_target_clear_mode = SubViewport.ClearMode.CLEAR_MODE_NEVER # Don't clear background
	sub_viewport.name = "MapRenderSubViewport_Temporary"
	var bounds_origin = total_bounds.position

	# --- 3. Temporarily Move Nodes to SubViewport ---
	print("...Moving %d nodes to SubViewport" % nodes_to_render.size())
	for node in nodes_to_render:
		var parent = node.get_parent()
		if parent and is_instance_valid(parent):
			# Retrieve stored original global position
			var original_gpos = original_global_positions.get(node, Vector2.ZERO) # Default to ZERO if not found (shouldn't happen)

			var canvas_item = node as CanvasItem
			original_parents[node] = parent
			original_transforms[node] = node.transform
			if canvas_item:
				original_z_indices[node] = canvas_item.z_index

			parent.remove_child(node)
			sub_viewport.add_child(node)

			# !!! CHANGE 2: Set local position !!!
			# Calculate desired local position within viewport
			var target_local_pos = original_gpos - bounds_origin
			node.position = target_local_pos # Set local position relative to viewport

			# Debug Print: Check calculated local position
			print("......Node: %s, Original Global: %s, Bounds Origin: %s, Target Local Pos: %s" % [node.name, original_gpos, bounds_origin, target_local_pos])


			if canvas_item and node in original_z_indices:
				canvas_item.z_index = original_z_indices[node]
		else:
			printerr("Node ", node.name, " had no valid parent, skipping move.")

	# --- 4. Add SubViewport to Scene Tree & Render ---
	add_child(sub_viewport)

	# Wait for rendering
	if Engine.is_editor_hint():
		print("Waiting for rendering server (will wait multiple frames)...")
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		# await RenderingServer.frame_post_draw
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

	# Retry logic
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


# --- Cleanup Function ---
# Needs to handle original_global_positions potentially if needed for restore,
# but cleanup mainly restores original transform relative to original parent.
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
				node.transform = transforms.get(node, Transform2D()) # Restore local transform
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
