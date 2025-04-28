extends Node2D


signal objective_updated(level_id, objective_id)
signal objective_completed(level_id, objective_id)
signal level_completed(level_id)
signal game_completed

var current_level = 1
var max_level = 4  # Now we specify the max level
var levels = {}

func _ready():
	# Initialize level objectives
	setup_levels()

func setup_levels():
	# Level 1 objectives
	levels[1] = {
		"defeat_enemies": {
			"title": "Defeat Enemies",
			"description": "Clear all the weak bridges in the city",
			"completed": false,
			"progress": 0,
			"max_progress": 1
		},
		"find_door": {
			"title": "Secret Door",
			"description": "Find the hidden exit",
			"completed": false,
			"progress": 0,
			"max_progress": 1
		}
	}
	
	# Level 2 objectives
	levels[2] = {
		"defeat_enemies": {
			"title": "Defeat Enemies",
			"description": "Clear all enemies in the factory",
			"completed": false,
			"progress": 0,
			"max_progress": 15
		},
		"find_door": {
			"title": "Secret Door",
			"description": "Find the passage to the cave",
			"completed": false,
			"progress": 0,
			"max_progress": 1
		}
	}
	
	# Level 3 objectives
	levels[3] = {
		"defeat_enemies": {
			"title": "Defeat Enemies",
			"description": "Clear all enemies in the castle",
			"completed": false,
			"progress": 0,
			"max_progress": 20
		},
		"find_door": {
			"title": "Secret Door",
			"description": "Find the passage to the final level",
			"completed": false,
			"progress": 0,
			"max_progress": 1
		}
	}
	
	# Level 4 (final level) objectives
	levels[4] = {
		"defeat_enemies": {
			"title": "Defeat Enemies",
			"description": "Defeat the Trojan Horse Viruses",
			"completed": false,
			"progress": 0,
			"max_progress": 5
		},
		"find_door": {
			"title": "Secret Door",
			"description": "Find the opening to leave the matrix",
			"completed": false,
			"progress": 0,
			"max_progress": 1
		}
	}

func complete_objective(level_id, objective_id):
	if not levels.has(level_id) or not levels[level_id].has(objective_id):
		return
		
	levels[level_id][objective_id]["completed"] = true
	levels[level_id][objective_id]["progress"] = levels[level_id][objective_id]["max_progress"]
	emit_signal("objective_completed", level_id, objective_id)
	emit_signal("objective_updated", level_id, objective_id)
	
	# Check if all objectives for this level are complete
	check_level_completion(level_id)

func update_progress(level_id, objective_id, amount):
	if not levels.has(level_id) or not levels[level_id].has(objective_id):
		return
		
	levels[level_id][objective_id]["progress"] += amount
	
	# Check if objective is now complete
	if levels[level_id][objective_id]["progress"] >= levels[level_id][objective_id]["max_progress"]:
		complete_objective(level_id, objective_id)
	else:
		emit_signal("objective_updated", level_id, objective_id)

func check_level_completion(level_id):
	if not levels.has(level_id):
		return
		
	var all_complete = true
	for obj_id in levels[level_id]:
		if not levels[level_id][obj_id]["completed"]:
			all_complete = false
			break
	
	if all_complete:
		emit_signal("level_completed", level_id)
		
		# Check if this was the final level
		if level_id == max_level:
			emit_signal("game_completed")

func get_level_objectives(level_id = current_level):
	if levels.has(level_id):
		return levels[level_id]
	return {}

func set_current_level(level_id):
	if levels.has(level_id):
		current_level = level_id
