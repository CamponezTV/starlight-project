class_name StringCatalog
## Todo texto que o jogador lê, achado nos arquivos do projeto. O jogo é escrito em
## português e cada texto em português é a chave da tradução (locale/en.po).
##
## Onde o catálogo procura:
## - Scripts: textos dentro de say(...), show_caption(...), choose(...) e tr(...), e em
##   constantes cujo nome termina em _TEXT ou _TEXTS.
## - Cenas e recursos: as propriedades de SCENE_PROPERTIES.
## Texto fora desses lugares não é traduzido (e não entra no catálogo).

const SCENE_PROPERTIES: Array[String] = ["text", "title", "description", "controls", "display_name", "intro_message", "end_message"]
const SCRIPT_CALLS: Array[String] = ["say", "show_caption", "choose", "tr"]
const SKIPPED_DIRS: Array[String] = ["res://addons", "res://tests", "res://tools", "res://.godot"]
const DIALOGUE_CALL := "say"


## Texto -> arquivos onde aparece, na ordem em que foi achado.
static func collect() -> Dictionary:
	var found := {}
	for path in _files("res://"):
		var source := FileAccess.get_file_as_string(path)
		var texts := _from_script(source) if path.ends_with(".gd") else _from_scene(source)
		for text in texts:
			var files: PackedStringArray = found.get(text, PackedStringArray())
			if not files.has(path):
				files.append(path)
			found[text] = files
	return found


## Só as falas (say): precisam caber em duas linhas na caixa de diálogo.
static func dialogue_lines() -> PackedStringArray:
	var lines := PackedStringArray()
	for path in _files("res://"):
		if path.ends_with(".gd"):
			for text in _call_texts(FileAccess.get_file_as_string(path), [DIALOGUE_CALL]):
				if not lines.has(text):
					lines.append(text)
	return lines


static func _files(dir: String) -> PackedStringArray:
	var result := PackedStringArray()
	if SKIPPED_DIRS.has(dir.trim_suffix("/")):
		return result
	for file in DirAccess.get_files_at(dir):
		if file.get_extension() in ["gd", "tscn", "tres"]:
			result.append(dir.path_join(file))
	for sub in DirAccess.get_directories_at(dir):
		result.append_array(_files(dir.path_join(sub)))
	return result


static func _from_scene(source: String) -> PackedStringArray:
	var pattern := RegEx.create_from_string("(?m)^(?:%s) = \"((?:[^\"\\\\]|\\\\.)*)\"$" % "|".join(SCENE_PROPERTIES))
	var texts := PackedStringArray()
	for found in pattern.search_all(source):
		_keep(texts, found.get_string(1).c_unescape())
	return texts


static func _from_script(source: String) -> PackedStringArray:
	var texts := _call_texts(source, SCRIPT_CALLS)
	var constant := RegEx.create_from_string("(?m)^const \\w+_TEXTS?\\b[^=\\n]*=")
	for found in constant.search_all(source):
		for text in _literals(source, found.get_end()):
			_keep(texts, text)
	return texts


static func _call_texts(source: String, calls: Array[String]) -> PackedStringArray:
	var texts := PackedStringArray()
	var pattern := RegEx.create_from_string("(?<![\\w.])(?:%s)\\(" % "|".join(calls))
	for found in pattern.search_all(source):
		# Pula a declaração da própria função (func say(...)).
		if source.substr(maxi(found.get_start() - 5, 0), 5) == "func ":
			continue
		for text in _literals(source, found.get_end() - 1):
			_keep(texts, text)
	return texts


## Os textos entre aspas a partir de `from`: até fechar o parêntese ou colchete aberto
## ali, ou até o fim da linha se nada abrir.
static func _literals(source: String, from: int) -> PackedStringArray:
	var texts := PackedStringArray()
	var depth := 0
	var i := from
	while i < source.length():
		var c := source[i]
		if c == "\"":
			var end := i + 1
			while end < source.length() and source[end] != "\"":
				end += 2 if source[end] == "\\" else 1
			var prefix := source[i - 1] if i > 0 else ""
			if prefix != "&" and prefix != "^":
				texts.append(source.substr(i + 1, end - i - 1).c_unescape())
			i = end + 1
			continue
		if c == "(" or c == "[":
			depth += 1
		elif c == ")" or c == "]":
			depth -= 1
			if depth <= 0:
				break
		elif c == "\n" and depth == 0:
			break
		elif c == "#" and depth == 0:
			break
		i += 1
	return texts


## Guarda só o que tem letra (números e símbolos não se traduzem).
static func _keep(texts: PackedStringArray, text: String) -> void:
	if RegEx.create_from_string("\\p{L}").search(text) != null and not texts.has(text):
		texts.append(text)
