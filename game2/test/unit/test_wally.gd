extends GutTest

var wally = load("res://scripts/player.gd")
func test_takehit():
	var wally = wally.new()
	var result = wally.takehit()
	
	assert_eq(result, "taken hit","Result should have been 'taken hit'")
	
