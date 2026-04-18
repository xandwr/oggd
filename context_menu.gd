@tool
class_name OggdContextMenu
extends EditorContextMenuPlugin

const AUDIO_EXTENSIONS: Array[String] = [
	"mp3",
	"wav",
	"flac",
	"aac",
	"m4a",
	"aiff",
	"aif",
	"opus",
	"wma",
	"ogg",
	"ogx",
]


func _popup_menu(paths: PackedStringArray) -> void:
	var audio_paths: Array[String] = []
	for path: String in paths:
		if path.get_extension().to_lower() in AUDIO_EXTENSIONS:
			audio_paths.append(path)
	if audio_paths.is_empty():
		return
	add_context_menu_item(
		"Convert to .ogg (new file)",
		func(_paths: Array) -> void: OggdConverter.convert_all(audio_paths, false)
	)
	add_context_menu_item(
		"Convert to .ogg (replace)",
		func(_paths: Array) -> void: OggdConverter.convert_all(audio_paths, true)
	)
