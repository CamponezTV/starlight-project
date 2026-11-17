extends Node
## Autoload "Settings": idioma, volumes, texto automático e tela cheia. Ficam em
## `save_path`, separado do progresso: um jogo novo não mexe nas configurações.
## Cada set_* aplica na hora, salva e avisa com `changed`.

signal changed

const LANGUAGES: Array[String] = ["pt_BR", "en"] ## O primeiro é o padrão (o jogo é escrito em português).
## Cada idioma aparece escrito nele mesmo, para quem não lê o atual achar o seu.
const LANGUAGE_NAMES := {"pt_BR": "Português", "en": "English"}
const BUSES: Array[StringName] = [&"Master", &"Music", &"SFX"]
const VOLUME_STEP := 0.1
const SECTION := "settings"

var save_path := "user://settings.cfg"
var language := LANGUAGES[0]
var auto_advance := false ## As falas passam sozinhas depois de um tempo de leitura.
var fullscreen := false

var _volumes := {} ## Bus -> volume de 0.0 a 1.0.
var _base_db := {} ## Bus -> volume do layout de áudio (o 100% de cada bus).


func _ready() -> void:
	for bus in BUSES:
		_base_db[bus] = AudioServer.get_bus_volume_db(_bus_index(bus))
	load_settings()


## Volume do bus, de 0.0 (mudo) a 1.0.
func volume(bus: StringName) -> float:
	return _volumes.get(bus, 1.0)


func set_language(code: String) -> void:
	assert(LANGUAGES.has(code), "idioma desconhecido: %s" % code)
	language = code
	_apply_and_save()


## Avança para o idioma seguinte da lista (ou o anterior, com `direction` -1).
func cycle_language(direction: int) -> void:
	var index := LANGUAGES.find(language)
	set_language(LANGUAGES[wrapi(index + direction, 0, LANGUAGES.size())])


func set_volume(bus: StringName, value: float) -> void:
	assert(BUSES.has(bus), "bus desconhecido: %s" % bus)
	_volumes[bus] = snappedf(clampf(value, 0.0, 1.0), VOLUME_STEP)
	_apply_and_save()


func set_auto_advance(value: bool) -> void:
	auto_advance = value
	_apply_and_save()


func set_fullscreen(value: bool) -> void:
	fullscreen = value
	_apply_and_save()


## Lê o arquivo (o que faltar fica no padrão) e aplica.
func load_settings() -> void:
	var config := ConfigFile.new()
	config.load(save_path)
	var saved_language: String = config.get_value(SECTION, "language", LANGUAGES[0])
	language = saved_language if LANGUAGES.has(saved_language) else LANGUAGES[0]
	for bus in BUSES:
		_volumes[bus] = clampf(config.get_value(SECTION, "volume_%s" % bus, 1.0), 0.0, 1.0)
	auto_advance = config.get_value(SECTION, "auto_advance", false)
	fullscreen = config.get_value(SECTION, "fullscreen", false)
	_apply()


## Volta tudo ao padrão (sem apagar o arquivo de outro lugar).
func reset() -> void:
	language = LANGUAGES[0]
	for bus in BUSES:
		_volumes[bus] = 1.0
	auto_advance = false
	fullscreen = false
	_apply_and_save()


func _apply_and_save() -> void:
	_apply()
	var config := ConfigFile.new()
	config.set_value(SECTION, "language", language)
	for bus in BUSES:
		config.set_value(SECTION, "volume_%s" % bus, volume(bus))
	config.set_value(SECTION, "auto_advance", auto_advance)
	config.set_value(SECTION, "fullscreen", fullscreen)
	config.save(save_path)
	changed.emit()


func _apply() -> void:
	TranslationServer.set_locale(language)
	for bus in BUSES:
		var index := _bus_index(bus)
		AudioServer.set_bus_mute(index, volume(bus) <= 0.0)
		if volume(bus) > 0.0:
			AudioServer.set_bus_volume_db(index, _base_db[bus] + linear_to_db(volume(bus)))
	_apply_window_mode()


func _apply_window_mode() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var wanted := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	if DisplayServer.window_get_mode() != wanted:
		DisplayServer.window_set_mode(wanted)


func _bus_index(bus: StringName) -> int:
	var index := AudioServer.get_bus_index(bus)
	assert(index >= 0, "o layout de áudio não tem o bus %s" % bus)
	return index
