# Scratch & Rise

## Proje Bilgisi
- **Tür:** 2D Incremental / Idle / Clicker
- **Motor:** Godot 4.x (GDScript)
- **Platform:** PC (Steam)
- **Fiyat:** $4.99
- **Tema:** Kazı kazan + kripto/kumar meme kültürü
- **Repo:** https://github.com/BYGGOLDENSTONE/scratch-and-rise
- **Godot Yolu:** D:\godot\Godot_v4.6-stable_win64_console.exe

## Tasarım Referansı
- `docs/GDD.md` — Tüm mekanikler, sayılar, formüller burada

## Mimari Kararlar
- **Component-based structure:** Her sistem bağımsız sahne/script. Kolay ekle/çıkar/değiştir
- **2D Objeler (Node2D):** Bilet, kazıma alanları, semboller, efektler
- **UI (Control):** Üst bar, yan paneller, popup'lar
- **Autoload:** GameState (oyun durumu), SaveManager (kayıt sistemi)
- **Maliyet formülü (tümü):** `baz * 1.15 ^ seviye`
- **Sayı formatı:** 1K, 1M, 1B, 1T, 1Qa, 1Qi...

## Proje Yapısı
```
incremental/
├── docs/GDD.md
├── scenes/
│   ├── main/          # Ana sahne
│   ├── ticket/        # Bilet & kazıma componentleri
│   ├── ui/            # UI panelleri (her biri ayrı sahne)
│   └── effects/       # Efekt sahneleri
├── scripts/
│   ├── autoload/      # GameState, SaveManager
│   ├── ticket/        # Bilet, alan, sembol mantığı
│   ├── systems/       # Yükseltme, building, eşleşme sistemleri
│   └── ui/            # UI script'leri
├── assets/
│   ├── sprites/       # Sembol görselleri, bilet görselleri
│   ├── audio/         # Ses efektleri, müzik
│   ├── fonts/         # Fontlar
│   └── shaders/       # Kazıma shader'ı vb.
├── .gitignore
├── CLAUDE.md
└── project.godot
```

---

## Faz Planı

### DEMO FAZLARI (Oynanabilir Demo)

| Faz | İsim | Kapsam | Durum |
|-----|------|--------|-------|
| D1 | Proje Altyapısı | Godot ayarları, klasör yapısı, autoload iskeletleri, ana sahne layout, placeholder UI | `166ecae` |
| D2 | Bilet & Kazıma | Bilet sahnesi (Node2D), tıklama ile kazıma, sembol atama, bilet tamamlanma | `6a44aaf` |
| D3 | Eşleşme & Coin | Eşleşme kontrolü (3/4+), coin hesaplama, üst bar, eşleşme sonuç ekranı, yeni bilet gelme | `569e3e4` |
| D4 | Yükseltmeler | Yükseltme paneli, eşleşme bonusu yükseltmeleri, maliyet formülü (scratch devre dışı) | `30a20a4` |
| D5 | Bilet Türleri | Kağıt/Bronz/Gümüş biletler, bilet seçim paneli, açılma koşulları, farklı alan+sembol havuzları | `d427062` |
| D6 | Buildings | İlk 3-4 building, BPS hesaplama, otomatik coin, building paneli UI | `bekliyor` |
| D7 | Save & Polish | Save/Load (JSON), otomatik kayıt, offline gelir, temel animasyonlar, UI düzeni | `bekliyor` |

### RELEASE FAZLARI (Tam Oyun)

| Faz | İsim | Kapsam | Durum |
|-----|------|--------|-------|
| R1 | Tüm İçerik | Kalan biletler (Altın→Efsanevi), özel semboller, kalan yükseltmeler, çalışan sistemi | `bekliyor` |
| R2 | Sinerji & Koleksiyon | 8+2 sinerji, sinerji albümü, koleksiyon sistemi (6 set), koleksiyon UI | `bekliyor` |
| R3 | Olaylar & Ödüller | Altın Bilet, Bull Run, Bear Market, Mega Jackpot, Whale Alert, 3'ten 1 seç, milestonelar | `bekliyor` |
| R4 | Prestige | Prestige mekaniği, Şans Yıldızı, prestige mağazası (14 bonus), sıfırlama akışı | `bekliyor` |
| R5 | Görsel & Ses | Kazıma shader'ı, GPUParticles2D, tüm animasyonlar, ses efektleri, müzik, neon casino stili | `bekliyor` |
| R6 | Başarımlar & Final | 40+ başarım, istatistik ekranı, Steam entegrasyonu, balans, son düzeltmeler | `bekliyor` |

### Tamamlanan Fazlar
_(Her faz tamamlandığında commit hash'i ile buraya taşınacak)_

---

## Commit Kuralları
- Her faz sonrası kullanıcı test eder → onaylarsa commit+push
- Commit mesajı formatı: `[D1] Proje altyapısı: autoload, ana sahne, klasör yapısı`
- Tamamlanan fazlar tabloda `commit_hash` ile referanslanır
