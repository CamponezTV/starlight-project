extends GutTest
## As estrelas perdidas guardadas (autoload Stars), salvas junto do progresso.

const LEVEL := "level_test"


func before_each() -> void:
	TestHelpers.use_test_save()


func after_each() -> void:
	TestHelpers.restore_save()


func test_nothing_is_found_at_first() -> void:
	assert_false(Stars.has(LEVEL, "a"))


func test_a_collected_star_stays_found() -> void:
	assert_true(Stars.collect(LEVEL, "a"), "a primeira vez conta")
	assert_true(Stars.has(LEVEL, "a"))
	assert_false(Stars.has(LEVEL, "b"), "as outras continuam perdidas")
	assert_false(Stars.has("outra_fase", "a"), "cada fase tem as suas")


func test_the_same_star_only_counts_once() -> void:
	watch_signals(Stars)
	Stars.collect(LEVEL, "a")
	assert_false(Stars.collect(LEVEL, "a"), "repetida não conta")
	assert_signal_emit_count(Stars, "collected", 1)


func test_forget_loses_every_star() -> void:
	Stars.collect(LEVEL, "a")
	Stars.forget()
	assert_false(Stars.has(LEVEL, "a"))


func test_saving_progress_keeps_the_stars() -> void:
	Stars.collect(LEVEL, "a")
	Story.save_progress(1)
	assert_true(Stars.has(LEVEL, "a"), "salvar o progresso não apaga as estrelas")
