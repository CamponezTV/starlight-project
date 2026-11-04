extends GutTest
## A vida (autoload Stars).


func before_each() -> void:
	Stars.reset()


func after_all() -> void:
	Stars.reset()


func test_starts_with_start_count() -> void:
	assert_eq(Stars.count, Stars.START_COUNT)


func test_gain_is_capped_at_max() -> void:
	for i in Stars.MAX_COUNT + 2:
		Stars.gain()
	assert_eq(Stars.count, Stars.MAX_COUNT)


func test_lose_stops_at_zero() -> void:
	for i in Stars.START_COUNT + 2:
		Stars.lose()
	assert_eq(Stars.count, 0)
	assert_true(Stars.is_empty())


func test_ratio_goes_from_zero_to_one() -> void:
	Stars.count = Stars.MAX_COUNT
	assert_eq(Stars.ratio(), 1.0)
	Stars.count = 0
	assert_eq(Stars.ratio(), 0.0)


func test_changing_count_emits_changed() -> void:
	watch_signals(Stars)
	Stars.lose()
	assert_signal_emitted_with_parameters(Stars, "changed", [Stars.START_COUNT - 1])
