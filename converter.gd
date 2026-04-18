@tool
class_name OggdConverter
extends RefCounted


static func _quality() -> int:
	return int(EditorInterface.get_editor_settings().get_setting("Oggd/vorbis_quality"))


static func convert_all(paths: Array[String], replace: bool) -> void:
	var ffmpeg: String = find_ffmpeg()
	if ffmpeg.is_empty():
		push_error("oggd: ffmpeg not found: install it and ensure it is in your PATH.")
		return

	for path: String in paths:
		_convert_one(ffmpeg, path, replace)

	EditorInterface.get_resource_filesystem().scan()


static func _convert_one(ffmpeg: String, res_path: String, replace: bool) -> void:
	var input_abs := ProjectSettings.globalize_path(res_path)
	var output_res := res_path.get_basename() + ".ogg"
	var output_abs := ProjectSettings.globalize_path(output_res)

	var output: Array = []
	var exit := OS.execute(
		ffmpeg,
		["-y", "-i", input_abs, "-c:a", "libvorbis", "-q:a", str(_quality()), output_abs],
		output,
		true,
	)

	if exit != 0:
		push_error("oggd: failed to convert '%s'\n%s" % [res_path, "\n".join(output)])
		return

	if replace and res_path != output_res:
		var import_abs := input_abs + ".import"
		if FileAccess.file_exists(import_abs):
			DirAccess.remove_absolute(import_abs)
		OS.move_to_trash(input_abs)

	print("oggd: %s -> %s" % [res_path.get_file(), output_res.get_file()])


static func find_ffmpeg() -> String:
	var candidates: Array[String] = [
		"ffmpeg",
		"/usr/bin/ffmpeg",
		"/usr/local/bin/ffmpeg",
		"/opt/homebrew/bin/ffmpeg",
		"C:/ProgramData/chocolatey/bin/ffmpeg.exe",
		"C:/ffmpeg/bin/ffmpeg.exe",
	]
	for candidate: String in candidates:
		var output: Array = []
		if OS.execute(candidate, ["-version"], output, true) == 0:
			return candidate
	return ""
