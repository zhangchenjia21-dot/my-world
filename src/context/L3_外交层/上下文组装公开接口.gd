## Context 模块的稳定公开入口；调用方只依赖组装合同，不接触其历史根级实现路径。
class_name ContextAssemblyPublicInterface
extends "res://src/context/上下文组装器.gd"

const RuntimeSettings := preload("res://src/运行时设置/L3_外交层/模型运行时设置公开接口.gd")


## 从 validated runtime settings 读取容量，失败不回退到硬编码预算。
func runtime_budget_metadata() -> Dictionary:
	return RuntimeSettings.new().context_budget_metadata()


const SourceContext := preload("res://src/首次开场/L3_外交层/续玩来源上下文公开接口.gd")
const CurationContext := preload("res://src/信息整理/L3_外交层/叙事整理上下文公开接口.gd")
const WorldContext := preload("res://src/世界回合/L3_外交层/世界回合上下文公开接口.gd")
const InventoryContext := preload("res://src/行囊/L3_外交层/行囊公开接口.gd")
const MechanicsContext := preload("res://src/行动判定/L3_外交层/公开机制历史公开接口.gd")

## 唯一普通 Narrative 组装入口；只从各域 L3 收取请求材料，不读 raw World 或 UI 偏好。
## required_instruction 仅供机制 owner 传入当前已决定的强制结果；不改变领域真相。
func assemble_session(runtime: Variant, projection: Dictionary = {}, required_instruction: String = "") -> Dictionary:
	if runtime == null or not runtime.is_ready() or runtime.conversation == null:
		return {"success":false,"status":"runtime_not_ready","message":"当前 Game 尚未安全打开。"}
	var budget := runtime_budget_metadata()
	if not budget.success: return budget
	var source := SourceContext.project_session(runtime)
	if not source.success: return source
	var blocks: Array = source.blocks.filter(func(b: Dictionary) -> bool: return b.tier == 0)
	if not required_instruction.is_empty(): blocks.append({"family":"mechanics_instruction","tier":0,"text":required_instruction})
	blocks.append_array(CurationContext.project_session(runtime))
	var world := WorldContext.new().project_session(runtime)
	for pair: Array in [["world",String(world.context_text)],["inventory",InventoryContext.project_context(runtime)],["mechanics",MechanicsContext.project_context(runtime)]]:
		if not String(pair[1]).is_empty(): blocks.append({"family":pair[0],"tier":1,"text":pair[1]})
	blocks.append_array(source.blocks.filter(func(b: Dictionary) -> bool: return b.tier == 2 and b.family != "style"))
	blocks.append_array(source.blocks.filter(func(b: Dictionary) -> bool: return b.family == "style"))
	var result := assemble_working_set(runtime.conversation.get_context_projection() if projection.is_empty() else projection, blocks, budget.context_budget)
	if result.has("context_stats"):
		for family: String in ["character","threads","world","inventory","mechanics","experiences","people","source","npc_source","style","conversation"]:
			if not result.context_stats.families.has(family):
				result.context_stats.families[family] = {"considered":0,"included":0,"omitted":0,"included_bytes":0,"omitted_bytes":0,"reason":"empty_or_not_current"}
		result.context_stats["materialized_world_turns"] = int(world.record_count)
		result.context_stats["rejected_world_turns"] = int(world.rejected_count)
	return result
