class_name FirstOpeningPublicInterface
extends "res://src/首次开场/L2_流程层/首次开场运行流程.gd"

## G4-07A backend seam：调用者先用 existing-only runtime 打开 exact Game，再注入本接口。
## 本接口不接收 Wizard/Source Library，因此结构上无法从 mutable Source current 重建 setup。
