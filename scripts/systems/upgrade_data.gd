class_name UpgradeData

## Yükseltme verileri. Preload ile erişilir.
## Maliyet: baz * 1.15 ^ seviye

const UPGRADES := {
	"paper_hands": {
		"name": "Paper Hands",
		"base_cost": 15,
		"max_level": 25,
		"category": "scratch",
		"effect_type": "scratch_power",
		"effect_per_level": 1,
		"description": "+1 alan/tık",
		"flavor": "Herkes bir yerden başlar",
	},
	"wider_strokes": {
		"name": "Wider Strokes",
		"base_cost": 500,
		"max_level": 15,
		"category": "scratch",
		"effect_type": "scratch_power",
		"effect_per_level": 2,
		"description": "+2 alan/tık",
		"flavor": "Büyük düşün, geniş kazı",
	},
	"lucky_charm": {
		"name": "Lucky Charm",
		"base_cost": 50,
		"max_level": 30,
		"category": "match",
		"effect_type": "match_bonus_pct",
		"effect_per_level": 25,
		"description": "Eşleşme ödülü +%25",
		"flavor": "Şans cesurları sever",
	},
	"ticket_guru": {
		"name": "Ticket Guru",
		"base_cost": 1000,
		"max_level": 20,
		"category": "match",
		"effect_type": "match_bonus_pct",
		"effect_per_level": 50,
		"description": "Eşleşme ödülü +%50",
		"flavor": "Bu işin uzmanıyız",
	},
}

## Yükseltme sırası (UI'da bu sırayla gösterilir)
## Kazıma yükseltmeleri (paper_hands, wider_strokes) büyük biletler açılınca eklenecek
const UPGRADE_ORDER := ["lucky_charm", "ticket_guru"]
