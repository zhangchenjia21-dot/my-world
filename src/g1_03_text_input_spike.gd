extends Control

const SAMPLE_PARAGRAPHS: PackedStringArray = [
	"夜雨沿着旧城区的青瓦往下淌，檐角的水珠在灯笼光里连成细线。巡夜人从石桥另一端走来，靴底踏过积水，声音被远处的钟声切成一段一段。",
	"茶馆已经打烊，木门却还留着一道窄缝。柜台后的老人压低声音，说北门今天换了三次守卫，而城外商队直到日落也没有进城。",
	"你翻开桌上的旧地图，纸页边缘已经起毛。几条用朱砂补过的道路穿过山谷，其中一条旁边写着：雨季之后不可通行。",
	"少女把斗篷上的雨水抖在门外，随后把一枚磨损严重的铜牌放到桌面。她没有解释来历，只问你是否愿意在天亮前去一趟河港。",
	"风从半开的窗户灌进来，带着潮湿木料和煤烟的味道。楼下有人拖动桌椅，隔壁房间则传来短促的争执声，很快又归于安静。",
	"城墙上的火把依次亮起。远处山脊被云层遮住，只能偶尔看到一道苍白的轮廓。守门官检查完文书后没有立即放行，而是重新看了你一眼。",
	"账本最后几页的数字明显比前面潦草，几笔货款被重复划掉又重新写上。夹在纸页之间的车票显示，某个人三天前已经离开本城。",
	"清晨的市场还没完全醒来，摊贩正在支起棚布。卖鱼的人和药材商为了昨夜的一辆马车争论不休，两个人给出的方向完全相反。"
]

const STREAM_CHUNKS: PackedStringArray = [
	"雨声更密了一些，",
	"门外传来脚步，",
	"灯火在风里晃动，",
	"有人压低了声音，",
	"远处钟声再次响起，",
	"你面前的地图被风吹动了一角。"
]

@onready var transcript: RichTextLabel = %Transcript
@onready var player_input: TextEdit = %PlayerInput
@onready var append_button: Button = %AppendButton
@onready var burst_button: Button = %BurstButton
@onready var stream_button: Button = %StreamButton
@onready var clear_button: Button = %ClearButton
@onready var submit_button: Button = %SubmitButton
@onready var status_label: Label = %StatusLabel
@onready var stream_timer: Timer = %StreamTimer

var sequence := 0
var stream_remaining := 0


func _ready() -> void:
	append_button.pressed.connect(_append_sample)
	burst_button.pressed.connect(_append_burst)
	stream_button.pressed.connect(_toggle_stream)
	clear_button.pressed.connect(_clear_transcript)
	submit_button.pressed.connect(_append_player_input)
	player_input.gui_input.connect(_on_player_input_gui_input)
	stream_timer.timeout.connect(_on_stream_tick)

	_seed_transcript(48)
	_update_status()
	player_input.grab_focus()


func _seed_transcript(paragraph_count: int) -> void:
	transcript.clear()
	sequence = 0
	transcript.add_text("G1-03 中文长文本 / 输入 Foundation Spike\n")
	transcript.add_text("请测试滚动、鼠标选择、Ctrl+C、中文输入，以及下方的批量/持续追加。\n\n")
	for index in range(paragraph_count):
		_append_generated_paragraph(index, false)
	transcript.scroll_to_line(0)


func _append_generated_paragraph(sample_index: int, update_status: bool = true) -> void:
	sequence += 1
	var sample := SAMPLE_PARAGRAPHS[sample_index % SAMPLE_PARAGRAPHS.size()]
	transcript.add_text("【测试段落 %03d】%s\n\n" % [sequence, sample])
	if update_status:
		_update_status()


func _append_sample() -> void:
	_append_generated_paragraph(sequence)


func _append_burst() -> void:
	for index in range(300):
		_append_generated_paragraph(sequence + index, false)
	_update_status()


func _toggle_stream() -> void:
	if stream_timer.is_stopped():
		stream_remaining = 300
		stream_button.text = "停止模拟持续追加"
		stream_timer.start()
	else:
		_stop_stream()


func _on_stream_tick() -> void:
	if stream_remaining <= 0:
		_stop_stream()
		return

	var chunk := STREAM_CHUNKS[sequence % STREAM_CHUNKS.size()]
	transcript.add_text(chunk)
	sequence += 1
	stream_remaining -= 1

	if sequence % 6 == 0:
		transcript.add_text("\n")
	if stream_remaining % 25 == 0:
		_update_status()
	if stream_remaining <= 0:
		transcript.add_text("\n\n")
		_stop_stream()


func _stop_stream() -> void:
	stream_timer.stop()
	stream_remaining = 0
	stream_button.text = "开始模拟持续追加"
	_update_status()


func _clear_transcript() -> void:
	_stop_stream()
	transcript.clear()
	sequence = 0
	transcript.add_text("文本已清空。可以继续输入、追加或重新制造长文本压力。\n\n")
	_update_status()


func _append_player_input() -> void:
	var value := player_input.text.strip_edges()
	if value.is_empty():
		status_label.text = "请输入中文或其他文本后再追加。"
		return

	sequence += 1
	transcript.add_text("【玩家输入 %03d】\n%s\n\n" % [sequence, value])
	player_input.clear()
	_update_status()
	player_input.grab_focus()


func _on_player_input_gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.ctrl_pressed and key_event.keycode == KEY_ENTER:
			_append_player_input()
			player_input.accept_event()


func _update_status() -> void:
	var stream_state := "持续追加：停止"
	if not stream_timer.is_stopped():
		stream_state = "持续追加：运行中（剩余 %d 块）" % stream_remaining

	status_label.text = "字符：%d ｜ 段落：%d ｜ %s" % [
		transcript.get_total_character_count(),
		transcript.get_paragraph_count(),
		stream_state,
	]
