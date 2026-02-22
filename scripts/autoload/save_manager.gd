extends Node

## Kayıt/yükleme sistemi. JSON tabanlı, otomatik kayıt + yedek.

const SAVE_PATH := "user://save_main.json"
const BACKUP_PATH := "user://save_backup.json"

var _auto_save_timer: Timer
var _backup_timer: Timer


func _ready() -> void:
	_auto_save_timer = Timer.new()
	_auto_save_timer.wait_time = 30.0
	_auto_save_timer.autostart = true
	_auto_save_timer.timeout.connect(_on_auto_save)
	add_child(_auto_save_timer)

	_backup_timer = Timer.new()
	_backup_timer.wait_time = 300.0
	_backup_timer.autostart = true
	_backup_timer.timeout.connect(_on_backup_save)
	add_child(_backup_timer)
	print("[SaveManager] Initialized — auto save 30s, backup 5min")


func save_game() -> void:
	var data := {
		"coins": GameState.coins,
		"total_coins_earned": GameState.total_coins_earned,
		"scratch_power": GameState.scratch_power,
		"current_ticket_type": GameState.current_ticket_type,
		"upgrades": GameState.upgrades,
		"buildings": GameState.buildings,
		"total_tickets_scratched": GameState.total_tickets_scratched,
		"total_matches": GameState.total_matches,
		"match_bonus_pct": GameState.match_bonus_pct,
		"timestamp": Time.get_unix_time_from_system(),
	}
	# Yedek: mevcut save'i backup'a kopyala
	if FileAccess.file_exists(SAVE_PATH):
		var existing := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if existing:
			var backup := FileAccess.open(BACKUP_PATH, FileAccess.WRITE)
			if backup:
				backup.store_string(existing.get_as_text())
	# Yeni save yaz
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		print("[SaveManager] Game saved")


func load_game() -> bool:
	var path := SAVE_PATH
	if not FileAccess.file_exists(path):
		path = BACKUP_PATH
		if not FileAccess.file_exists(path):
			print("[SaveManager] No save file found")
			return false
		print("[SaveManager] Main save missing, loading backup")

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return false

	var json := JSON.new()
	var result := json.parse(file.get_as_text())
	if result != OK:
		print("[SaveManager] Failed to parse save: ", json.get_error_message())
		return false

	var data: Dictionary = json.data
	GameState.coins = int(data.get("coins", 0))
	GameState.total_coins_earned = int(data.get("total_coins_earned", 0))
	GameState.scratch_power = int(data.get("scratch_power", 1))
	GameState.current_ticket_type = data.get("current_ticket_type", "paper")
	GameState.upgrades = data.get("upgrades", {})
	GameState.buildings = data.get("buildings", {})
	GameState.total_tickets_scratched = int(data.get("total_tickets_scratched", 0))
	GameState.total_matches = int(data.get("total_matches", 0))
	GameState.recalculate_upgrades()
	GameState.recalculate_buildings()
	print("[SaveManager] Game loaded from ", path)
	return true


func _on_auto_save() -> void:
	save_game()


func _on_backup_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var src := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if src:
			var dst := FileAccess.open(BACKUP_PATH, FileAccess.WRITE)
			if dst:
				dst.store_string(src.get_as_text())
				print("[SaveManager] Backup saved")


## Offline gelir: son kayıt zamanı ile şimdiki zaman farkından hesapla
func calc_offline_earnings() -> Dictionary:
	var path := SAVE_PATH
	if not FileAccess.file_exists(path):
		path = BACKUP_PATH
		if not FileAccess.file_exists(path):
			return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}

	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return {}

	var data: Dictionary = json.data
	var saved_time: float = data.get("timestamp", 0.0)
	if saved_time <= 0.0:
		return {}

	var now := Time.get_unix_time_from_system()
	var elapsed := now - saved_time
	if elapsed < 60.0:  # 1 dakikadan az ise offline gelir yok
		return {}

	var offline_bps: float = GameState.bps
	if offline_bps <= 0.0:
		return {}

	# Maks 24 saat (86400 sn)
	elapsed = minf(elapsed, 86400.0)
	var earnings := int(elapsed * offline_bps * 0.5)
	if earnings <= 0:
		return {}

	return {
		"elapsed": elapsed,
		"earnings": earnings,
	}


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		print("[SaveManager] Emergency save on quit")
