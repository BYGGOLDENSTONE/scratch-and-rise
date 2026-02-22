extends Node

## Oyun durumunu tutan global autoload.
## Tüm sistemler buradan okur/yazar.

# --- Sinyaller ---
signal coins_changed(new_amount: int)
signal bps_changed(new_bps: float)
signal ticket_type_changed(new_type: String)

# --- Para ---
var coins: int = 0:
	set(value):
		coins = max(value, 0)
		coins_changed.emit(coins)

var total_coins_earned: int = 0

# --- Kazıma ---
var scratch_power: int = 1  # Tıklama başına kazınan alan sayısı (hesaplanmış)

# --- Yükseltme Bonusları (hesaplanmış) ---
var match_bonus_pct: float = 0.0  # Eşleşme ödülü bonus yüzdesi

# --- Bilet ---
var current_ticket_type: String = "paper":
	set(value):
		current_ticket_type = value
		ticket_type_changed.emit(current_ticket_type)

# --- BPS (Bilet Per Second) ---
var bps: float = 0.0:
	set(value):
		bps = value
		bps_changed.emit(bps)

# --- Yükseltmeler: { "upgrade_id": level } ---
var upgrades: Dictionary = {}

# --- Buildings: { "building_id": count } ---
var buildings: Dictionary = {}

# --- İstatistikler ---
var total_tickets_scratched: int = 0
var total_matches: int = 0


func _ready() -> void:
	print("[GameState] Initialized")


func add_coins(amount: int) -> void:
	total_coins_earned += amount
	coins += amount


func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		return true
	return false


func get_upgrade_level(upgrade_id: String) -> int:
	return upgrades.get(upgrade_id, 0)


func get_building_count(building_id: String) -> int:
	return buildings.get(building_id, 0)


## Maliyet formülü: baz * 1.15 ^ seviye
func calc_cost(base_cost: int, level: int) -> int:
	return int(base_cost * pow(1.15, level))


## Yükseltme etkilerini yeniden hesapla. Her upgrade alımı sonrası çağrılır.
func recalculate_upgrades() -> void:
	var UD = preload("res://scripts/systems/upgrade_data.gd")
	scratch_power = 1
	match_bonus_pct = 0.0
	for upgrade_id in upgrades:
		var data: Dictionary = UD.UPGRADES.get(upgrade_id, {})
		if data.is_empty():
			continue
		var level: int = upgrades[upgrade_id]
		match data["effect_type"]:
			"scratch_power":
				scratch_power += data["effect_per_level"] * level
			"match_bonus_pct":
				match_bonus_pct += data["effect_per_level"] * level


## Büyük sayıları okunabilir formata çevir
func format_number(n: int) -> String:
	if n < 1_000:
		return str(n)
	elif n < 1_000_000:
		return "%.1fK" % (n / 1_000.0)
	elif n < 1_000_000_000:
		return "%.1fM" % (n / 1_000_000.0)
	elif n < 1_000_000_000_000:
		return "%.1fB" % (n / 1_000_000_000.0)
	else:
		return "%.1fT" % (n / 1_000_000_000_000.0)
