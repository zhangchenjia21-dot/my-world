extends SceneTree

## MW-005 Three Kingdoms Literary Style Primer —— 接线与 authority separation focused 测试。
## 只证明架构接线：generation fingerprint 变化、new Game 冻结 Primer、Opening/普通 GM
## context 在非事实边界下看到一次、project_world_only() 完全排除、old Game 不受
## Source current 前进影响。不断言任何文风质量。
## Provider 全部走桩；real Provider calls = 0。

const Contract := preload("res://src/source/L3_外交层/Source合同公开接口.gd")
const Library := preload("res://src/source/L3_外交层/Source库公开接口.gd")
const FinalCreate := preload("res://src/最终建局/L3_外交层/原子最终建局公开接口.gd")
const Creation := preload("res://src/建局/L3_外交层/建局公开接口.gd")
const Runtime := preload("res://src/runtime/当前游戏会话运行时.gd")
const Opening := preload("res://src/首次开场/L3_外交层/首次开场公开接口.gd")
const Projector := preload("res://src/首次开场/L1_器件层/游戏本地开场上下文投影器.gd")
const Persistence := preload("res://src/persistence/L3_外交层/世界持久化公开接口.gd")
const Fixture := preload("res://tests/g4_05/G4_05测试夹具.gd")
const StubAdapter := preload("res://tests/g4_07a/首次开场桩适配器.gd")

const WORLD_PKG := "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/天下未定"
const PLAYER_PKG := "res://tests/fixtures/g4_02r1/full_fidelity/汉末三国/刘备"
const PRIMER_INPUT := "res://docs/tasks/inputs/MW-005_THREE_KINGDOMS_STYLE_PRIMER_V0_1.txt"
## MW-005 之前 production current generation 的 fingerprint（发布证据见 docs/g4_09p1）。
const OLD_FINGERPRINT := "acea0b2afbaf5305f40456cb93b60c94d536066cee794d75bf5e4b44eebe8a47"
## Primer P08 中的唯一 marker；不出现在任何事实性 World/Character section。
const PRIMER_MARKER := "听弦歌也略知雅意"
const STYLE_TYPE := "literary_style_reference"
const STYLE_SECTION_FILE := "sections/11_literary_style_reference.md"

var _failures := 0
var _fixture := Fixture.new()
var _root := ""
var _new_fingerprint := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_root = _argument("--root=")
	if _root.find("mw005") < 0:
		_fail("必须提供 task-owned --root，且路径包含 mw005")
		return _finish()
	_fixture.reset_directory(_root)
	_test_contract_load_and_fingerprint()
	await _test_new_game_freeze_opening_and_world_only()
	_test_old_game_freeze_across_current_advance()
	_finish()


## packet §9.1：world_pack.v0.2 接受并保留 literary_style_reference section；
## 其字节进入 generation fingerprint（有/无该 section 得到不同 fingerprint，
## 且去掉该 section 后精确还原 MW-005 之前的 production generation）。
func _test_contract_load_and_fingerprint() -> void:
	var loaded: Dictionary = Contract.new().load_world_pack(WORLD_PKG)
	_check(loaded.success, "world_pack.v0.2 loads package carrying literary_style_reference")
	if not loaded.success:
		return
	var primer_text := FileAccess.get_file_as_string(PRIMER_INPUT)
	_check(not primer_text.is_empty() and primer_text.contains(PRIMER_MARKER), "canonical Primer input readable and carries marker")
	var found := false
	for section: Dictionary in loaded.source.semantic_sections:
		if String(section.get("section_type", "")) == STYLE_TYPE:
			found = true
			_check(String(section.get("disclosure", "")) == "gm_reference", "style section disclosure is gm_reference")
			_check(String(section.get("content", "")) == primer_text, "style section content is the exact approved Primer input")
	_check(found, "loaded model preserves exactly the literary_style_reference section")

	var lib_new := Library.new(_root.path_join("lib-new"))
	var installed_new: Dictionary = lib_new.install_world_pack(WORLD_PKG)
	_check(installed_new.success, "new generation publishes through existing Source Library flow")
	if not installed_new.success:
		return
	_new_fingerprint = String(installed_new.generation.identity.generation_fingerprint)
	_check(_new_fingerprint != OLD_FINGERPRINT, "Primer bytes change generation fingerprint")

	var stripped := _stripped_package(_root.path_join("pkg-stripped"))
	var lib_old := Library.new(_root.path_join("lib-old-probe"))
	var installed_old: Dictionary = lib_old.install_world_pack(stripped)
	_check(installed_old.success, "stripped package (Primer removed) still publishes")
	if installed_old.success:
		_check(String(installed_old.generation.identity.generation_fingerprint) == OLD_FINGERPRINT,
			"package minus style section reproduces the exact pre-MW-005 production generation")


## packet §9.2/9.3/9.4/9.5：new Game 冻结含 Primer 的 generation；普通 GM context 在
## 非事实边界下看到 Primer 恰好一次；first opening 经同一 frozen Game-local 路径看到；
## project_world_only() 完全排除；Source current 前进后 frozen setup 不变。
func _test_new_game_freeze_opening_and_world_only() -> void:
	var case_root := _case_root("new-game")
	var installed := _fixture.install_packages(case_root.path_join("source-library"), [
		{"type": "world", "path": WORLD_PKG},
		{"type": "character", "path": PLAYER_PKG},
	])
	_check(installed.success, "task-owned library installs Primer World + Player")
	if not installed.success:
		return
	var library: RefCounted = installed.library
	var world_generation := _fixture.find_generation(installed.installed, "world.han_end.unsettled_realm")
	var player_generation := _fixture.find_generation(installed.installed, "character.han_end.liu_bei")
	_check(String(world_generation.identity.generation_fingerprint) == _new_fingerprint, "new install reuses the same immutable Primer generation")

	var composition := _composition(library, world_generation, player_generation)
	var creator := FinalCreate.new(library, case_root.path_join("creation"), case_root.path_join("library"), case_root.path_join("games"))
	var created: Dictionary = creator.create_or_resume("mw005-new", composition)
	_check(created.success, "new Game final-creates on the Primer generation")
	if not created.success:
		return
	var setup := _read_frozen_setup(created)
	_check(String(setup.world.provenance.generation_fingerprint) == _new_fingerprint, "new Game freezes the Primer generation exactly")
	_check(_frozen_style_content(setup).contains(PRIMER_MARKER), "frozen Game-local setup carries the Primer without consulting Source current")

	var projector := Projector.new()
	var projected: Dictionary = projector.project(setup)
	_check(projected.success, "ordinary GM context projection succeeds on Primer setup")
	if projected.success:
		var text := String(projected.context_text)
		var boundary := text.find("## Literary Style Reference")
		_check(boundary >= 0, "ordinary GM context carries a distinct non-factual literary boundary")
		_check(text.find("不构成当前 Game 的世界事实或既定未来", boundary) > boundary, "boundary explicitly denies current-fact/future authority")
		_check(text.count(PRIMER_MARKER) == 1, "ordinary GM context sees the Primer exactly once")
		_check(boundary >= 0 and text.find(PRIMER_MARKER) > boundary, "Primer renders under the boundary, not inside factual World sections")
		_check(text.find("world-identity-ownership") >= 0 and text.find("world-identity-ownership") < boundary, "factual World sections still render before the boundary")

	## first opening 与 ordinary Narrative 共用 project()；这里走真实 Opening 流程证明。
	var runtime := Runtime.new()
	_check(runtime.open_existing_game(String(created.database_path)).success, "new Game existing-only opens")
	var stub := StubAdapter.new()
	var opening := Opening.new(runtime, stub)
	root.add_child(opening)
	await process_frame
	var started: Dictionary = opening.start_first_opening()
	_check(started.success and String(started.status) == "streaming", "first opening starts through the frozen Game-local path")
	var serialized := JSON.stringify(opening.last_request_messages)
	_check(serialized.count(PRIMER_MARKER) == 1 and serialized.contains("## Literary Style Reference"),
		"first opening Provider-visible context includes the Primer once under the boundary")
	opening.queue_free()

	var world_only: Dictionary = projector.project_world_only(setup)
	_check(world_only.success, "project_world_only() succeeds on Primer setup")
	if world_only.success:
		var baseline := String(world_only.context_text)
		_check(not baseline.contains(PRIMER_MARKER), "project_world_only() excludes Primer content")
		_check(not baseline.contains(STYLE_TYPE) and not baseline.contains("Literary Style Reference"),
			"project_world_only() excludes even the literary_style_reference token/boundary")
		_check(baseline.contains("world-identity-ownership"), "project_world_only() still carries factual World sections")

	## Source current 前进（发布 stripped=旧 generation 为 newer current）后 frozen setup 不变。
	var stripped := _stripped_package(case_root.path_join("pkg-stripped"))
	var advanced: Dictionary = library.install_world_pack(stripped)
	_check(advanced.success and String(advanced.generation.identity.generation_fingerprint) == OLD_FINGERPRINT,
		"Source current advances to the pre-MW-005 generation after Game creation")
	var setup_after := _read_frozen_setup(created)
	_check(String(setup_after.world.provenance.generation_fingerprint) == _new_fingerprint,
		"frozen provenance survives Source current advance")
	_check(_frozen_style_content(setup_after).contains(PRIMER_MARKER), "frozen Primer survives Source current advance")


## packet §9.6：old Game（创建于无 Primer generation）在 Source current 前进到
## Primer generation 后保持原样；同一 library 之后创建的 new Game 才冻结新 generation。
func _test_old_game_freeze_across_current_advance() -> void:
	var case_root := _case_root("old-game")
	var stripped := _stripped_package(case_root.path_join("pkg-stripped"))
	var installed := _fixture.install_packages(case_root.path_join("source-library"), [
		{"type": "world", "path": stripped},
		{"type": "character", "path": PLAYER_PKG},
	])
	_check(installed.success, "old-generation library installs stripped World + Player")
	if not installed.success:
		return
	var library: RefCounted = installed.library
	var old_world := _fixture.find_generation(installed.installed, "world.han_end.unsettled_realm")
	_check(String(old_world.identity.generation_fingerprint) == OLD_FINGERPRINT, "old Game pins the pre-MW-005 generation")

	var creator := FinalCreate.new(library, case_root.path_join("creation"), case_root.path_join("library"), case_root.path_join("games"))
	var old_created: Dictionary = creator.create_or_resume("mw005-old", _composition(library, old_world, _fixture.find_generation(installed.installed, "character.han_end.liu_bei")))
	_check(old_created.success, "old Game final-creates on the pre-MW-005 generation")
	if not old_created.success:
		return
	var old_setup := _read_frozen_setup(old_created)
	_check(_frozen_style_content(old_setup).is_empty(), "old frozen setup has no literary style section")
	var projector := Projector.new()
	var old_projected: Dictionary = projector.project(old_setup)
	_check(old_projected.success and not String(old_projected.context_text).contains(PRIMER_MARKER)
		and not String(old_projected.context_text).contains("Literary Style Reference"),
		"old Game GM context has no Primer and no boundary")

	var advanced: Dictionary = library.install_world_pack(WORLD_PKG)
	_check(advanced.success and String(advanced.generation.identity.generation_fingerprint) == _new_fingerprint,
		"Source current advances to the Primer generation")
	var current: Dictionary = library.get_current_world("world.han_end.unsettled_realm")
	_check(current.success and String(current.generation.identity.generation_fingerprint) == _new_fingerprint, "current now points at the Primer generation")

	var old_setup_after := _read_frozen_setup(old_created)
	_check(String(old_setup_after.world.provenance.generation_fingerprint) == OLD_FINGERPRINT, "old Game provenance stays on the pre-MW-005 generation")
	var old_reprojected: Dictionary = projector.project(old_setup_after)
	_check(old_reprojected.success and not String(old_reprojected.context_text).contains(PRIMER_MARKER),
		"old Game gains no silent style injection after Source current advances")

	var new_created: Dictionary = creator.create_or_resume("mw005-after-advance", _composition(library, advanced.generation, _fixture.find_generation(installed.installed, "character.han_end.liu_bei")))
	_check(new_created.success, "post-advance new Game final-creates")
	if new_created.success:
		var new_setup := _read_frozen_setup(new_created)
		_check(String(new_setup.world.provenance.generation_fingerprint) == _new_fingerprint
			and _frozen_style_content(new_setup).contains(PRIMER_MARKER),
			"only Games created after publication freeze the Primer generation")


## 复制三国 World package 并以文本手术精确移除 MW-005 追加的 style 声明与内容文件，
## 字节上还原 MW-005 之前的 production authoring package（声明无嵌套花括号）。
func _stripped_package(target_path: String) -> String:
	_fixture.copy_package(WORLD_PKG, target_path)
	DirAccess.remove_absolute(target_path.path_join(STYLE_SECTION_FILE))
	var source_path := target_path.path_join("source.json")
	var text := FileAccess.get_file_as_string(source_path)
	var start := text.find(',{"section_id":"literary-style-reference"')
	if start < 0:
		_fail("stripped package 构造失败：找不到 style 声明起点")
		return target_path
	var end := text.find("}", start) + 1
	text = text.substr(0, start) + text.substr(end)
	var file := FileAccess.open(source_path, FileAccess.WRITE)
	file.store_string(text)
	file.close()
	return target_path


func _frozen_style_content(setup: Dictionary) -> String:
	for section: Dictionary in setup.world.source_projection.semantic_sections:
		if String(section.get("section_type", "")) == STYLE_TYPE:
			return String(section.get("content", ""))
	return ""


func _composition(library: RefCounted, world_generation: RefCounted, player_generation: RefCounted) -> Dictionary:
	var creation := Creation.new(library)
	creation.select_world(world_generation)
	creation.select_entry("t0-208-red-cliffs-eve")
	creation.confirm_expansion_none()
	creation.select_player(player_generation)
	creation.set_settings("MW005文风接线", "Light", "")
	return creation.composition_snapshot()


func _read_frozen_setup(created: Dictionary) -> Dictionary:
	var persistence := Persistence.new()
	var opened := persistence.open_database(String(created.database_path))
	if not opened.success:
		return {}
	var root := persistence.get_timeline_node(String(created.game_id), String(created.root_node_id))
	persistence.close_database()
	if not root.success:
		return {}
	return root.get("world_state", {})


func _case_root(name: String) -> String:
	var path := _root.path_join(name)
	DirAccess.make_dir_recursive_absolute(path)
	return path


func _argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix).replace("\\", "/")
	return ""


func _check(condition: bool, label: String) -> void:
	if condition:
		print("MW-005 PRIMER PASS | %s" % label)
	else:
		_failures += 1
		push_error("MW-005 PRIMER FAIL | %s" % label)


func _fail(label: String) -> void:
	_failures += 1
	push_error("MW-005 PRIMER FAIL | %s" % label)


func _finish() -> void:
	print("MW-005 PRIMER | done failures=%d" % _failures)
	quit(1 if _failures > 0 else 0)
