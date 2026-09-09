extends RefCounted

## Debug 仅允许闭集结构元数据；未知原始 code/message 不进入投影。
const CAPACITY := 64
const LANES := {"narrative": "叙事", "world": "世界语义", "identity": "人物身份", "character": "角色", "experiences": "重要经历", "people": "人物卡", "threads": "事务", "recommendations": "推荐行动", "save": "存档", "restore": "恢复进度"}
const TERMINALS := {"accepted": "已接受", "committed": "已提交", "ready": "就绪", "unavailable": "不可用", "failed": "失败", "stale": "已过期", "cancelled": "已取消", "restored": "已恢复", "saved": "已保存"}
const CHANGES := {"changed": "有变化", "no-change": "无变化", "unknown": "变化未知"}
const REASONS := {"already_current": "已处于所选进度", "historical_skipped": "历史回合未重新处理", "already_materialized": "已复用当前历史结果", "ready": "", "committed": "", "initial_committed": "", "accepted": "", "saved": "已保存当前进度", "restored": "已切换进度，旧诊断已清除", "input_unavailable": "当前没有合法推荐机会", "malformed_response": "模型响应结构无效", "response_oversized": "模型响应超过大小限制", "provider_failure": "模型服务调用失败", "timeout": "请求超时", "cancelled": "请求已取消", "stale": "当前回合已被替换，旧结果已丢弃", "persistence_failure": "持久化失败", "initial_profile_unavailable": "初始角色材料暂不可用", "input_oversized": "输入材料超过大小限制", "unknown_failure": "处理未完成，请稍后重试", "backup_warning": "存档已保存，安全备份刷新失败"}

static func reason(code: String) -> String:
	if REASONS.has(code): return code
	if code in ["analysis_start_failure", "start_failed", "analysis_provider_failure", "missing_key", "transport", "http"]: return "provider_failure"
	if code in ["analysis_timeout"]: return "timeout"
	if code in ["analysis_cancelled"]: return "cancelled"
	if code in ["stale_analysis", "stale_history", "stale_parent", "stale_initial"]: return "stale"
	if code in ["empty_analysis", "malformed_analysis", "invalid_changes", "too_many_changes", "invalid_change", "analysis_malformed", "invalid_initial_result"]: return "malformed_response"
	if code in ["invalid_storage", "invalid_initial_storage", "initial_read_failure"]: return "persistence_failure"
	return "unknown_failure"

static func row(lane: String, index: int, terminal: String, change: String, code: String, counts: Dictionary = {}, elapsed: int = -1) -> Dictionary:
	if not LANES.has(lane) or not TERMINALS.has(terminal) or not CHANGES.has(change): return {}
	var safe_counts := {}
	for key: String in ["changes", "knowledge", "actors", "bindings", "added", "removed", "updated", "total"]:
		if counts.has(key): safe_counts[key] = clampi(int(counts[key]), 0, 1000000)
	var safe_code := reason(code)
	return {"lane": lane, "turn": index, "terminal": terminal, "change": change,
		"lane_label": LANES[lane], "terminal_label": TERMINALS[terminal], "change_label": CHANGES[change],
		"code": safe_code, "reason": REASONS[safe_code], "counts": safe_counts, "elapsed_ms": clampi(elapsed, -1, 3600000)}
