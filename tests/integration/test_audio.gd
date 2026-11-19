extends GutTest
## Áudio: buses configurados, todo som ligado a um arquivo no bus certo e a troca de música.

const SCENES_WITH_SFX := [
	"res://player/player.tscn",
	"res://main/main.tscn",
	"res://menu/menu.tscn",
	"res://entities/star_pickup/star_pickup.tscn",
	"res://entities/dash_crystal/dash_crystal.tscn",
	"res://entities/checkpoint/checkpoint.tscn",
	"res://entities/room_exit/room_exit.tscn",
	"res://entities/dash_unlock/dash_unlock.tscn",
	"res://ui/skill_showcase.tscn",
	"res://ui/level_complete.tscn",
]
const MUSIC_BUS := &"Music"
const SFX_BUS := &"SFX"
const PLAYER_SCENE := preload("res://player/player.tscn")
const TRACK_A := preload("res://music/cave.wav")
const TRACK_B := preload("res://music/summit.wav")
const MUSIC_DIR := "res://music/"


func test_music_and_sfx_buses_exist() -> void:
	assert_ne(AudioServer.get_bus_index(MUSIC_BUS), -1)
	assert_ne(AudioServer.get_bus_index(SFX_BUS), -1)


## Toda trilha volta ao começo sem parar (Loop Mode = Forward no import).
func test_every_track_loops() -> void:
	var tracks := 0
	for file in ResourceLoader.list_directory(MUSIC_DIR):
		if file.get_extension() == "wav":
			tracks += 1
			var track := load(MUSIC_DIR + file) as AudioStreamWAV
			assert_eq(track.loop_mode, AudioStreamWAV.LOOP_FORWARD, "%s não faz loop" % file)
	assert_gt(tracks, 0)


func test_every_sound_effect_has_a_stream_on_the_sfx_bus() -> void:
	for path: String in SCENES_WITH_SFX:
		var scene := (load(path) as PackedScene).instantiate()
		for node in scene.find_children("*", "AudioStreamPlayer", true, false):
			var player := node as AudioStreamPlayer
			if player.bus == MUSIC_BUS:
				continue
			assert_eq(player.bus, SFX_BUS, "%s:%s no bus errado" % [path, player.name])
			assert_not_null(player.stream, "%s:%s sem som" % [path, player.name])
		scene.free()


func test_jumping_plays_the_jump_sound() -> void:
	var world := Node2D.new()
	add_child_autofree(world)
	var player: Player = PLAYER_SCENE.instantiate()
	world.add_child(player)
	player._jump(0)
	assert_true((player.get_node("JumpSound") as AudioStreamPlayer).playing)


## No meio da troca, a soma das potências das duas faixas fica perto de 1: o volume não afunda.
func test_crossfade_keeps_the_loudness() -> void:
	Music.play(TRACK_A, 0.0)
	Music.play(TRACK_B, 1.0)
	await wait_seconds(0.5)
	var power := 0.0
	for node in Music.find_children("*", "AudioStreamPlayer", false, false):
		power += pow((node as AudioStreamPlayer).volume_linear, 2.0)
	assert_almost_eq(power, 1.0, 0.05)
	Music.stop(0.0)


func test_stopping_mid_crossfade_silences_both_tracks() -> void:
	Music.play(TRACK_A, 0.0)
	Music.play(TRACK_B) # A faixa A ainda está sumindo.
	Music.stop(0.0)
	assert_null(Music.current())
	for node in Music.find_children("*", "AudioStreamPlayer", false, false):
		assert_false((node as AudioStreamPlayer).playing, "%s continuou tocando" % (node as AudioStreamPlayer).stream.resource_path)
