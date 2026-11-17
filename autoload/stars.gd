extends Node
## Autoload "Stars": as estrelas perdidas que o Jupiter já guardou, por fase.
## Ficam salvas junto do progresso da campanha (o arquivo da Story). Um jogo novo esquece todas.

signal collected(level_id: String, star_id: String)

const SAVE_SECTION := "stars"


## Guarda a estrela `star_id` da fase `level_id`. Devolve false se ela já estava guardada.
func collect(level_id: String, star_id: String) -> bool:
	var found := _found_in(level_id)
	if found.has(star_id):
		return false
	found.append(star_id)
	var config: ConfigFile = Story.load_save()
	config.set_value(SAVE_SECTION, level_id, found)
	config.save(Story.save_path)
	collected.emit(level_id, star_id)
	return true


func has(level_id: String, star_id: String) -> bool:
	return _found_in(level_id).has(star_id)


func forget() -> void:
	var config: ConfigFile = Story.load_save()
	if config.has_section(SAVE_SECTION):
		config.erase_section(SAVE_SECTION)
		config.save(Story.save_path)


func _found_in(level_id: String) -> PackedStringArray:
	var config: ConfigFile = Story.load_save()
	return config.get_value(SAVE_SECTION, level_id, PackedStringArray())
