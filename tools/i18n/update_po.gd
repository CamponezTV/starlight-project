extends SceneTree
## Atualiza locale/en.po com o catálogo: textos novos entram com a tradução vazia, os que
## sumiram do jogo saem e as traduções que já existem ficam. Rode depois de escrever
## textos novos:
##   godot --headless -s res://tools/i18n/update_po.gd
## Depois preencha os msgstr vazios (o teste de traduções aponta os que faltam).

const PO_PATH := "res://locale/en.po"
const LANGUAGE := "en"


func _initialize() -> void:
	var known := _existing_translations()
	var catalog := StringCatalog.collect()
	var lines := PackedStringArray([
		"msgid \"\"", "msgstr \"\"",
		"\"Content-Type: text/plain; charset=UTF-8\\n\"",
		"\"Language: %s\\n\"" % LANGUAGE, "",
	])
	var missing := 0
	for text: String in catalog:
		var where := ", ".join((catalog[text] as PackedStringArray)).replace("res://", "")
		var translated: String = known.get(text, "")
		missing += 1 if translated.is_empty() else 0
		lines.append_array(["#: " + where, "msgid " + _quote(text), "msgstr " + _quote(translated), ""])
	var file := FileAccess.open(PO_PATH, FileAccess.WRITE)
	file.store_string("\n".join(lines))
	file.close()
	print("%s: %d textos, %d sem tradução" % [PO_PATH, catalog.size(), missing])
	quit()


func _existing_translations() -> Dictionary:
	var known := {}
	if not FileAccess.file_exists(PO_PATH):
		return known
	var translation := load(PO_PATH) as Translation
	for text in translation.get_message_list():
		known[text] = translation.get_message(text)
	return known


func _quote(text: String) -> String:
	return "\"%s\"" % text.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n")
