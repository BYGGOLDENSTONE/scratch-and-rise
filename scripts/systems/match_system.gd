class_name MatchSystem

## Eşleşme kontrolü ve ödül hesaplama.
## Kurallar: 3 aynı=x5, 4+=x20, eşleşme yok=teselli (x0.2)

const TD = preload("res://scripts/systems/ticket_data.gd")


static func evaluate(symbols: Array, ticket_type: String) -> Dictionary:
	var base_reward: int = TD.get_ticket(ticket_type)["base_reward"]
	var counts := _count_symbols(symbols)
	var matches := _find_matches(counts)
	return _calc_reward(matches, counts, base_reward)


static func _count_symbols(symbols: Array) -> Dictionary:
	var counts := {}
	for s in symbols:
		counts[s] = counts.get(s, 0) + 1
	return counts


static func _find_matches(counts: Dictionary) -> Array:
	var matches := []
	for symbol in counts:
		if counts[symbol] >= 3:
			matches.append({"symbol": symbol, "count": counts[symbol]})
	# En büyük eşleşme önce
	matches.sort_custom(func(a, b): return a["count"] > b["count"])
	return matches


static func _calc_reward(matches: Array, counts: Dictionary, base_reward: int) -> Dictionary:
	if matches.is_empty():
		var consolation := maxi(1, int(base_reward * 0.2))
		return {
			"total": consolation,
			"lines": [{"text": "Eşleşme yok — teselli: %d Coin" % consolation, "type": "consolation"}],
			"is_jackpot": false,
		}

	var total := 0
	var lines := []
	var is_jackpot := false

	for m in matches:
		var symbol: String = m["symbol"]
		var count: int = m["count"]
		var emoji: String = TD.get_symbol_emoji(symbol)
		var multiplier := 1
		var label := ""

		if count == 3:
			multiplier = 5
			label = "3x EŞLEŞME!"
		elif count >= 4:
			multiplier = 20
			label = "JACKPOT!"
			is_jackpot = true

		var amount := base_reward * multiplier
		total += amount
		lines.append({
			"text": "%s x%d = %s → %d x%d = %d Coin" % [emoji, count, label, base_reward, multiplier, amount],
			"type": "jackpot" if count >= 4 else "match",
		})

	return {
		"total": total,
		"lines": lines,
		"is_jackpot": is_jackpot,
	}
