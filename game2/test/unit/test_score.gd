extends GutTest
var global = preload("res://scripts/Global.gd")
func test_score():
	var global = global.new()
	var result = global.score
	assert_eq(result,Global.score,"Score increase success")
