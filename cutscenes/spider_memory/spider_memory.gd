extends Cutscene
## Memória antes do chefe 2: cinco anos atrás, Sophie tranca Jupiter no galpão como
## castigo. No escuro, uma aranha desce do teto e a sombra dela cresce na parede. Horas
## depois, o avô o encontra e mostra que a aranha era pequenininha.

const JUPITER := preload("res://dialogue/speakers/jupiter_child.tres")
const SOPHIE := preload("res://dialogue/speakers/sophie.tres")
const GRANDPA := preload("res://dialogue/speakers/grandpa.tres")

const SPIDER_DESCENT := 5.0
const SHADOW_SCALE_SCARY := 2.2
const SHADOW_SCALE_SMALL := 0.5
const TREMBLE_PIXELS := 1.0
const KID_CLOSE_UP := Vector2(150, 124)
const DOOR_VIEW := Vector2(230, 110)
const HUG_CLOSE_UP := Vector2(238, 118)

var _tremble: Tween

@onready var _jupiter: Actor = $Stage/Jupiter
@onready var _grandpa: Actor = $Stage/Grandpa
@onready var _spider: Sprite2D = $Stage/Spider
@onready var _thread: Line2D = $Stage/Thread
@onready var _shadow: Sprite2D = $Stage/SpiderShadow
@onready var _spider_low: Marker2D = $Stage/SpiderLow
@onready var _door_light: Polygon2D = $Stage/DoorLight
@onready var _flashlight: PointLight2D = $Stage/Grandpa/Flashlight
@onready var _hug_spot: Marker2D = $Stage/HugSpot
@onready var _camera: Camera2D = $Camera
@onready var _door_sound: AudioStreamPlayer = $DoorSound
@onready var _skitter_sound: AudioStreamPlayer = $SkitterSound


func _ready() -> void:
	super()
	cast = {JUPITER: _jupiter, GRANDPA: _grandpa}
	_grandpa.hide()


func _process(_delta: float) -> void:
	_thread.points = PackedVector2Array([Vector2(_spider.position.x, 0), _spider.position])


func _run() -> void:
	Transition.fade_out(0.0)
	await show_caption("Cinco anos antes", 2.8)
	_door_sound.play()
	await wait(1.2)
	await say(SOPHIE, "Fica aí pensando no que você fez.")
	await say(SOPHIE, "Quem sabe assim você aprende.")
	end_conversation()
	Transition.fade_in(3.0)
	await move_camera(_camera, KID_CLOSE_UP, 2.0, 3.0)
	await say(JUPITER, "Tá escuro...")
	await say(JUPITER, "Me deixa sair... por favor...")
	end_conversation()
	await wait(1.0)
	await _spider_descends()
	_jupiter.pose = "crouch_up"
	await say(JUPITER, "...!")
	await say(JUPITER, "Vai embora... vai embora...")
	end_conversation()
	_start_trembling()
	await wait(2.0)
	await Transition.fade_out(2.0)
	await show_caption("Horas depois", 2.5)
	_stop_trembling()
	_jupiter.pose = "crouch"
	Transition.fade_in(1.5)
	await wait(1.0)
	await _grandpa_opens_the_door()
	await say(GRANDPA, "Jupiter? Meu Deus... quem te trancou aqui?")
	_jupiter.pose = "stand"
	await say(JUPITER, "Vovô!")
	end_conversation()
	await move(_jupiter, _hug_spot.global_position, 1.0)
	_grandpa.pose = "kneel_hug"
	_jupiter.pose = "hug"
	await move_camera(_camera, HUG_CLOSE_UP, 2.0, 1.5)
	await say(GRANDPA, "Pronto, pronto. Eu tô aqui.")
	await say(JUPITER, "Tinha uma aranha... enorme...")
	await _light_on_the_spider()
	await say(GRANDPA, "Essa pequenininha aqui? Olha só... ela tem mais medo de você do que você dela.")
	await say(GRANDPA, "Sabe o que as aranhas fazem? Tecem teias que nem constelações. Cada fio ligando uma estrela na outra.")
	await say(JUPITER, "...Mesmo assim eu não gosto delas.")
	await say(GRANDPA, "Tudo bem. Ninguém precisa gostar de tudo.")
	await say(GRANDPA, "Vamos pra casa. Eu converso com a Sophie.")
	end_conversation()
	await wait(1.5)
	await Transition.fade_out(2.5)
	await show_caption("Ele conversou com ela.", 2.8)
	await show_caption("Não adiantou.", 2.8)
	await show_caption("Capítulo 2: em breve", 3.5)


## A aranha desce pelo fio e a sombra dela cresce na parede.
func _spider_descends() -> void:
	_skitter_sound.play()
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	tween.tween_property(_spider, "position", _spider_low.position, SPIDER_DESCENT)
	tween.tween_property(_shadow, "modulate:a", 0.85, SPIDER_DESCENT)
	tween.tween_property(_shadow, "scale", Vector2.ONE * SHADOW_SCALE_SCARY, SPIDER_DESCENT)
	await tween.finished


func _grandpa_opens_the_door() -> void:
	_door_sound.play()
	_grandpa.show()
	_grandpa.pose = "flashlight"
	var tween := create_tween().set_parallel()
	tween.tween_property(_door_light, "modulate:a", 1.0, 0.6)
	tween.tween_property(_camera, "global_position", DOOR_VIEW, 1.5)
	await tween.finished


## A lanterna mostra a aranha de verdade: a sombra encolhe.
func _light_on_the_spider() -> void:
	_flashlight.enabled = true
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	tween.tween_property(_shadow, "scale", Vector2.ONE * SHADOW_SCALE_SMALL, 1.5)
	tween.tween_property(_shadow, "modulate:a", 0.25, 1.5)
	await tween.finished


func _start_trembling() -> void:
	var origin := _jupiter.position
	_tremble = create_tween().set_loops()
	_tremble.tween_property(_jupiter, "position:x", origin.x + TREMBLE_PIXELS, 0.05)
	_tremble.tween_property(_jupiter, "position:x", origin.x - TREMBLE_PIXELS, 0.05)


func _stop_trembling() -> void:
	if _tremble != null:
		_tremble.kill()
