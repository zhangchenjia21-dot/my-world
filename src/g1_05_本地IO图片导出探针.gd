extends Control

## G1-05 本地 IO / 动态图片 / Windows Export Foundation Spike。
## 只证明三件事：user:// 极小探针跨启动写读、三类图片“写文件 → 从 filesystem 重新 decode → UI 显示”、
## Editor 与导出 EXE 两种运行形态识别。
## 契约边界：本探针不是正式 Save / Timeline / World Pack；已有 probe 损坏或 schema 不匹配必须 FAIL，
## 不得静默覆盖成“成功”（INV-02）；不得读取或显示任何 Provider API Key（INV-04）。

const PROBE_SCHEMA := "g1_05_probe_v1"
const PROBE_DIR := "user://g1_05_probe/"
const PROBE_FILE := PROBE_DIR + "probe.json"
const IMAGE_DIR := PROBE_DIR + "images/"
const IMAGE_SIZE := 96

@onready var runtime_label: Label = %RuntimeLabel
@onready var io_status_label: Label = %IOStatusLabel
@onready var path_label: Label = %PathLabel
@onready var marker_label: Label = %MarkerLabel
@onready var portrait_status: Label = %PortraitStatus
@onready var scene_status: Label = %SceneStatus
@onready var map_status: Label = %MapStatus
@onready var portrait_texture: TextureRect = %PortraitTexture
@onready var scene_texture: TextureRect = %SceneTexture
@onready var map_texture: TextureRect = %MapTexture
@onready var rerun_io_button: Button = %RerunIOButton
@onready var reload_images_button: Button = %ReloadImagesButton

var io_passed := false


func _ready() -> void:
	rerun_io_button.pressed.connect(_run_local_io_probe)
	reload_images_button.pressed.connect(_run_image_probe)
	_update_runtime_mode()
	_run_local_io_probe()
	_run_image_probe()
	_print_summary()


## 本地探针：建目录 → 读旧值（损坏/schema 不匹配即 FAIL 且不覆盖）→ 递增 → 写入 → 关闭 → 重开读回比对。
func _run_local_io_probe() -> void:
	io_passed = false
	path_label.text = "probe: %s ｜ 本机路径: %s" % [PROBE_FILE, ProjectSettings.globalize_path(PROBE_FILE)]

	var make_dir_error := DirAccess.make_dir_recursive_absolute(IMAGE_DIR)
	if make_dir_error != OK:
		_fail_io("创建探针目录失败，错误码 %d。" % make_dir_error)
		return

	var previous_count := 0
	var previous_marker := "(none)"
	if FileAccess.file_exists(PROBE_FILE):
		var parsed: Variant = _read_probe_json()
		if typeof(parsed) != TYPE_DICTIONARY:
			_fail_io("已有 probe 文件损坏（不是 JSON object）；按 INV-02 不覆盖。")
			return
		var data: Dictionary = parsed
		if String(data.get("schema", "")) != PROBE_SCHEMA:
			_fail_io("已有 probe schema 不匹配；按 INV-02 不覆盖。")
			return
		var count_value: Variant = data.get("launch_count", -1.0)
		if typeof(count_value) != TYPE_FLOAT and typeof(count_value) != TYPE_INT:
			_fail_io("已有 probe launch_count 类型非法；按 INV-02 不覆盖。")
			return
		previous_count = int(count_value)
		previous_marker = String(data.get("current_marker", "(missing)"))

	var current_count := previous_count + 1
	var current_marker := "%d-%d" % [int(Time.get_unix_time_from_system()), Time.get_ticks_msec()]

	var write_error := _write_probe_json({
		"schema": PROBE_SCHEMA,
		"launch_count": current_count,
		"current_marker": current_marker,
	})
	if write_error != OK:
		_fail_io("写入 probe 失败，错误码 %d。" % write_error)
		return

	# 关闭后重新打开并读回，必须得到与刚写入完全一致的状态，否则 FAIL。
	var verified: Variant = _read_probe_json()
	if typeof(verified) != TYPE_DICTIONARY:
		_fail_io("重新打开 probe 后无法解析。")
		return
	var verified_data: Dictionary = verified
	if String(verified_data.get("schema", "")) != PROBE_SCHEMA \
			or int(verified_data.get("launch_count", -1)) != current_count \
			or String(verified_data.get("current_marker", "")) != current_marker:
		_fail_io("读回内容与刚写入的状态不一致。")
		return

	io_passed = true
	io_status_label.text = "Local IO: PASS"
	marker_label.text = "launch_count = %d ｜ previous marker = %s ｜ current marker = %s" % [
		current_count, previous_marker, current_marker,
	]


func _read_probe_json() -> Variant:
	var file := FileAccess.open(PROBE_FILE, FileAccess.READ)
	if file == null:
		return null
	var text := file.get_as_text()
	file.close()
	return JSON.parse_string(text)


func _write_probe_json(payload: Dictionary) -> Error:
	var file := FileAccess.open(PROBE_FILE, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(payload))
	file.close()
	return OK


func _fail_io(message: String) -> void:
	io_status_label.text = "Local IO: FAIL"
	marker_label.text = message


## 三类图片 fixture：每类都走完整链路“运行时生成 → 写入 PNG 文件 → 从 filesystem 重新 decode → ImageTexture → UI”。
## 禁止把内存 Image 直接赋给 UI 冒充动态文件加载（DEC-04）。
func _run_image_probe() -> void:
	_probe_single_image("Portrait", Color(0.85, 0.35, 0.30), portrait_status, portrait_texture)
	_probe_single_image("Scene", Color(0.25, 0.55, 0.85), scene_status, scene_texture)
	_probe_single_image("Map", Color(0.35, 0.75, 0.40), map_status, map_texture)


func _probe_single_image(role: String, base_color: Color, status_label: Label, texture_rect: TextureRect) -> void:
	var path := IMAGE_DIR + role.to_lower() + ".png"

	var image := Image.create(IMAGE_SIZE, IMAGE_SIZE, false, Image.FORMAT_RGB8)
	image.fill(base_color)
	# 白色边框让三类 fixture 在纯色之外仍有可检查的结构差异。
	for index in range(IMAGE_SIZE):
		image.set_pixel(index, 0, Color.WHITE)
		image.set_pixel(index, IMAGE_SIZE - 1, Color.WHITE)
		image.set_pixel(0, index, Color.WHITE)
		image.set_pixel(IMAGE_SIZE - 1, index, Color.WHITE)

	var save_error := image.save_png(path)
	if save_error != OK:
		status_label.text = "%s image: FAIL（写入错误码 %d）" % [role, save_error]
		return

	# 从 filesystem 重新 decode/load，而不是复用上面的内存 Image。
	var loaded := Image.new()
	var load_error := loaded.load(path)
	if load_error != OK or loaded.is_empty():
		status_label.text = "%s image: FAIL（加载错误码 %d）" % [role, load_error]
		return

	texture_rect.texture = ImageTexture.create_from_image(loaded)
	status_label.text = "%s image: PASS" % role


func _update_runtime_mode() -> void:
	if OS.has_feature("editor"):
		runtime_label.text = "运行形态: Editor / engine-run"
	else:
		runtime_label.text = "运行形态: exported executable"


## 输出一行式摘要到 stdout，供 console / 导出 EXE 的自动化证据采集使用。
func _print_summary() -> void:
	print("[G1-05] runtime=%s" % ("editor" if OS.has_feature("editor") else "exported"))
	print("[G1-05] io=%s" % ("PASS" if io_passed else "FAIL"))
	print("[G1-05] %s ｜ %s ｜ %s" % [portrait_status.text, scene_status.text, map_status.text])
	print("[G1-05] probe=%s" % ProjectSettings.globalize_path(PROBE_FILE))
