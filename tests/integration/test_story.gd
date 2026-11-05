extends GutTest
## A campanha (autoload Story): passos válidos e na ordem da história.


func test_every_step_has_a_title_and_a_scene() -> void:
	assert_gt(Story.steps.size(), 0)
	for step in Story.steps:
		assert_false(step.title.is_empty())
		assert_not_null(step.scene, "%s sem cena" % step.title)


func test_step_kind_matches_its_scene() -> void:
	for step in Story.steps:
		var root := step.scene.instantiate()
		if step.kind == StoryStep.Kind.LEVEL:
			assert_true(root is Level, "%s deveria ser uma fase" % step.title)
		else:
			assert_true(root is Cutscene, "%s deveria ser uma cutscene" % step.title)
		root.free()


func test_level_steps_run_inside_the_game() -> void:
	for step in Story.steps:
		var node := Story.instantiate_step(step)
		if step.kind == StoryStep.Kind.LEVEL:
			assert_true(node is Main)
			assert_eq((node as Main).level_scene, step.scene)
		node.free()


func test_campaign_opens_with_the_prologue_and_ends_after_the_first_boss() -> void:
	assert_eq(Story.steps[0].kind, StoryStep.Kind.CUTSCENE, "começa com o prólogo")
	assert_eq(Story.steps[-1].kind, StoryStep.Kind.CUTSCENE, "termina com uma cena")
	var titles := Story.steps.map(func(step: StoryStep) -> String: return step.title)
	assert_lt(titles.find("A Queda"), titles.find("Chefe: Sophie"))


func test_outside_the_campaign_has_no_index() -> void:
	assert_eq(Story.current_index(), -1)
