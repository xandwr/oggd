@tool
extends EditorPlugin

var _context_menu: OggdContextMenu


func _enter_tree() -> void:
	_setup_settings()
	call_deferred("_check_ffmpeg")


func _check_ffmpeg() -> void:
	var found: bool = not OggdConverter.find_ffmpeg().is_empty()
	var dialog := AcceptDialog.new()
	dialog.exclusive = false
	EditorInterface.get_base_control().add_child(dialog)
	if found:
		dialog.title = "oggd"
		dialog.dialog_text = "ffmpeg found, oggd is ready. enjoy!\n-xandwr"
		dialog.confirmed.connect(dialog.queue_free)
		dialog.canceled.connect(dialog.queue_free)
		dialog.popup_centered()
		_context_menu = OggdContextMenu.new()
		add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM, _context_menu)
	else:
		dialog.title = "oggd"
		dialog.dialog_text = "ffmpeg not found in PATH: disabling oggd.\n\nInstall ffmpeg and ensure it is accessible from your system PATH."
		dialog.confirmed.connect(_disable_self.bind(dialog))
		dialog.canceled.connect(_disable_self.bind(dialog))
		dialog.popup_centered()


func _disable_self(dialog: AcceptDialog) -> void:
	dialog.queue_free()
	EditorInterface.set_plugin_enabled("oggd", false)


func _setup_settings() -> void:
	var settings := EditorInterface.get_editor_settings()
	if settings.has_setting("oggd/vorbis_quality"):
		settings.erase("oggd/vorbis_quality")
	if not settings.has_setting("Oggd/vorbis_quality"):
		settings.set_setting("Oggd/vorbis_quality", 6)
	settings.set_initial_value("Oggd/vorbis_quality", 6, false)
	settings.add_property_info({
		"name": "Oggd/vorbis_quality",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0,10,1",
	})


func _exit_tree() -> void:
	if is_instance_valid(_context_menu):
		remove_context_menu_plugin(_context_menu)
	_context_menu = null
