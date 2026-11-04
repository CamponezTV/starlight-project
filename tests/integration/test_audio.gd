extends GutTest
## Áudio: buses configurados e todo som ligado a um arquivo no bus certo.

const SCENES_WITH_SFX := [
	"res://player/player.tscn",
	"res://main/main.tscn",
	"res://menu/menu.tscn",
	"res://entities/star_pickup/star_pickup.tscn",
	"res://entities/dash_crystal/dash_crystal.tscn",
	"res://entities/checkpoint/checkpoint.tscn",
	"res://entities/room_exit/room_exit.tscn",
]
const MUSIC_BUS := &"Music"
const SFX_BUS := &"SFX"
const PLAYER_SCENE := preload("res://player/player.tscn")


func test_music_and_sfx_buses_exist() -> void:
	assert_ne(AudioServer.get_bus_index(MUSIC_BUS), -1)
	assert_ne(AudioServer.get_bus_index(SFX_BUS), -1)


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
	var player: Player = PLAYER_SCENE.instantiate()
	add_child_autofree(player)
	player._jump()
	assert_true((player.get_node("JumpSound") as AudioStreamPlayer).playing)
