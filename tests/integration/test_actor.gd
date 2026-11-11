extends GutTest
## Atores das cutscenes: pose escolhe o quadro, piscam sozinhos e mexem a boca enquanto
## falam. A Cutscene liga a boca de quem está no `cast` durante a fala.

const GRANDPA_SCENE := preload("res://characters/busts/grandpa.tscn")
const BOX_SCENE := preload("res://dialogue/dialogue_box.tscn")
const CAPTION_SCENE := preload("res://ui/caption.tscn")
const GRANDPA := preload("res://dialogue/speakers/grandpa.tres")

var _actor: Actor


func before_each() -> void:
	_actor = GRANDPA_SCENE.instantiate()
	add_child_autofree(_actor)


func test_pose_picks_the_first_frame_of_that_pose() -> void:
	_actor.pose = "smile"
	assert_eq(_actor.frame, _actor.poses.find("smile") * Actor.VARIANTS)


func test_unknown_pose_keeps_the_current_frame() -> void:
	_actor.pose = "sad"
	var frame := _actor.frame
	_actor.pose = "dançando"
	assert_eq(_actor.frame, frame)


func test_talking_alternates_the_mouth() -> void:
	_actor.pose = "neutral"
	_actor.talking = true
	var frames := {}
	for i in 30:
		await wait_process_frames(1)
		frames[_actor.frame] = true
	var base := _actor.poses.find("neutral") * Actor.VARIANTS
	assert_true(frames.has(base + Actor.VARIANT_TALK), "deveria abrir a boca")


func test_blinks_on_its_own() -> void:
	var frames := {}
	for i in 60:
		await wait_seconds(0.1)
		frames[_actor.frame % Actor.VARIANTS] = true
	assert_true(frames.has(Actor.VARIANT_BLINK), "deveria piscar em 6 s")


func test_speaker_in_the_cast_talks_until_the_line_is_typed() -> void:
	var cutscene := Cutscene.new()
	cutscene.advances_story = false
	var box := BOX_SCENE.instantiate()
	box.name = "DialogueBox"
	cutscene.add_child(box)
	var caption := CAPTION_SCENE.instantiate()
	caption.name = "Caption"
	cutscene.add_child(caption)
	add_child_autofree(cutscene)
	cutscene.cast = {GRANDPA: _actor}
	cutscene.say(GRANDPA, "Quem sabe um dia, meu neto.")
	await wait_process_frames(2)
	assert_true(_actor.talking)
	TestHelpers.tap(&"ui_accept")
	await wait_process_frames(1)
	assert_false(_actor.talking, "para de falar quando a fala aparece inteira")
