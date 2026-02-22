# Scratch & Rise - Game Design Document

## Genel Bakış
- **Tür:** 2D Incremental / Idle / Clicker
- **Motor:** Godot 4.x (GDScript)
- **Platform:** PC (Steam), sonrası Mobil
- **Fiyat:** $4.99
- **Tema:** Kazı kazan biletleri + kripto/kumar meme kültürü
- **İlham:** Cookie Clicker (ilerleme modeli) + gerçek kazı kazan hissi
- **Oyun Süresi:** Sonsuz (bitiş noktası yok)

## Konsept
Oyuncu meteliksiz başlar. Ücretsiz kağıt biletleri tıklayarak kazır, altındaki sembolleri açar. Semboller eşleşirse coin kazanır. Zamanla kazıma hızını artırır, daha değerli biletlere geçer, otomatik kazıma sistemleri kurar ve bir kazı kazan imparatorluğu inşa eder. Kripto ve kumar dünyasının meme kültürüyle sarmalanmış esprili bir ton.

---

## Temel Oyun Döngüsü

```
TIKLA (alan kazı) → SEMBOL AÇ → EŞLEŞME? → COİN KAZAN
       ↑                                        ↓
  Kazıma hızı artır                        YÜKSELTME AL
  (1 tıkla = daha çok alan)                     ↓
                                        Eşleşme bonusu artır
                                        Daha iyi bilet türü aç
                                        Oto-kazıyıcı al
                                        Building al (pasif bilet)
                                        Çalışan tut (geç oyun)
                                               ↓
                                           PRESTIGE
                                        (kalıcı bonuslar)
```

---

## Kazıma Mekaniği (Temel Mekanik)

### Bilet Yapısı
Her bilette **kazınacak alanlar** var. Her alanın altında gizli bir sembol.

```
Kağıt Bilet (6 alan):
┌─────────────────────────┐
│  [███]  [███]  [███]    │
│  [███]  [███]  [███]    │
│                         │
│  Kazı ve eşleşmeleri    │
│  bul! 🍀                │
└─────────────────────────┘
```

### Kazıma İşlemi
1. Oyuncu biletteki bir alana **tıklar** (veya LMB basılı tutup sürükler)
2. Tıklanan alan kazınır, altındaki sembol ortaya çıkar
3. Başlangıçta: **1 tıklama = 1 alan** kazınır
4. Yükseltmeyle: **1 tıklama = 2, 3, 4... alan** kazınır
5. Tüm alanlar kazınınca **eşleşme kontrolü** yapılır
6. Eşleşme sonucuna göre coin kazanılır
7. Sonraki bilet otomatik gelir

```
Kazıma sonrası:
┌─────────────────────────┐
│  [🍒]  [🍋]  [🍒]      │
│  [🍇]  [🍒]  [🍋]      │
│                         │
│  🍒 x3 = EŞLEŞME!      │
│  +150 Coin! 💰          │
└─────────────────────────┘
```

### Eşleşme Kuralları
- **2 aynı sembol** = eşleşme sayılmaz
- **3 aynı sembol** = eşleşme ödülü (baz x5)
- **4+ aynı sembol** = jackpot (baz x20)
- **Eşleşme yok** = teselli ödülü (baz x0.2, boş bilet yok)
- **Sinerji** = özel kombinasyon bonusu (baz x3-50 arası)

### Coin Kazanma Özeti
Kazıma para vermez. Kazıma **sembolleri açar**. Eşleşme **para kazandırır**.
Daha hızlı kazıma = dakikada daha çok bilet = daha çok eşleşme = daha çok coin.

---

## Bilet Sistemi

### Bilet Türleri
| Bilet | Maliyet | Alan Sayısı | Sembol Havuzu | Baz Ödül | Açılma |
|-------|---------|-------------|---------------|----------|--------|
| Kağıt | Ücretsiz | 6 | 3 (Kiraz, Limon, Üzüm) | 5 Coin | Başlangıç |
| Bronz | 10 | 8 | 5 (+Yıldız, Ay) | 25 Coin | 500 toplam coin |
| Gümüş | 50 | 9 | 7 (+Elmas, Kalp) | 100 Coin | 5K toplam coin |
| Altın | 250 | 10 | 9 (+7, Taç) | 500 Coin | 50K toplam coin |
| Platin | 1K | 12 | 11 (+Anka, Ejderha) | 2.5K Coin | 500K toplam coin |
| Elmas | 5K | 12 | 13 (+Gökkuşağı, Şimşek) | 10K Coin | 5M toplam coin |
| Efsanevi | 25K | 15 | 15 (+Kozmos, Sonsuzluk) | 50K Coin | Prestige sonrası |

**Daha fazla alan** = daha çok tıklama gerekir = kazıma hızı yükseltmesi daha önemli
**Daha fazla sembol** = eşleşme zorlaşır AMA ödüller büyür + sinerji çeşitliliği artar

### Özel Semboller (Nadir çıkar)
| Sembol | Efekt | Çıkma Şansı |
|--------|-------|-------------|
| Joker 🃏 | Her sembolle eşleşir | %5 |
| Çarpan x2 | Bilet toplam ödülünü x2 | %3 |
| Bomba 💣 | Tüm alanları anında kazır | %2 |
| Altın Yıldız ⭐ | Bilet ödülü x5 | %1 |
| Elmas 💎 | Garanti koleksiyon parçası | %0.5 |

---

## Sinerji Sistemi

Aynı bilette belirli semboller bir arada çıkarsa özel bonus tetiklenir.

### Sinerjiler (8 adet + 2 gizli)
| Sinerji | Koşul | Bonus | İlk Mümkün |
|---------|-------|-------|-----------|
| Meyve Kokteyli 🍹 | Kiraz + Limon + Üzüm (3 farklı meyve) | Ödül x3 | Kağıt |
| Lucky Seven 🎰 | 7 + 7 + 7 (3 adet 7) | Ödül x10 | Altın |
| Gece Gökyüzü 🌙 | Yıldız + Ay (ikisi birden) | Sonraki bilet ücretsiz | Bronz |
| Kraliyet 👑 | Taç + Elmas (ikisi birden) | CPS 30sn x5 | Altın |
| Ejderha Ateşi 🔥 | Ejderha + Anka (ikisi birden) | Tüm kazanç 1dk x10 | Platin |
| Kozmik Patlama 🌌 | Kozmos + Sonsuzluk + Şimşek | MEGA x50 | Elmas |
| Full House 🏠 | 5 alanın hepsi aynı sembol | Ödül x25 | Herhangi |
| Gökkuşağı 🌈 | 5+ farklı sembol aynı bilette | Ödül x5 | Gümüş |
| ??? | Gizli | ??? | ??? |
| ??? | Gizli | ??? | ??? |

### Sinerji Keşif Sistemi
- Keşfedilmemiş sinerjiler albümde "???" olarak görünür
- İlk keşifte: Büyük animasyon + "YENİ SİNERJİ KEŞFEDİLDİ!" + bonus ödül
- Keşfetme motivasyonu = uzun vadeli hedef

### Şeffaf Matematik
Bilet tamamlanınca hesaplama canlı gösterilir:
```
🍒 x3 = EŞLEŞME! → 5 x5 = 25 Coin
🍒 + 🍋 + 🍇 = MEYVE KOKTEYLİ! → x3!
Çarpan sembolü → x2!
─────────────────
Toplam: 25 x 3 x 2 = 150 Coin! 💰
```
Oyuncu her zaman neden kazandığını ve nasıl daha fazla kazanacağını bilir.

---

## Yükseltme Sistemi

Tek lineer ilerleme. Build path yok, herkes aynı yolu izler.
**Maliyet formülü (tümü):** `baz_maliyet * (1.15 ^ mevcut_seviye)`

### Kazıma Yükseltmeleri (Daha hızlı bilet bitirme)
| Yükseltme | Baz Maliyet | Etki | Max Svy | Flavor |
|-----------|------------|------|---------|--------|
| Paper Hands | 15 | 1 tıklama +1 alan kazır | 25 | *"Herkes bir yerden başlar"* |
| Speed Scratch | 100 | Kazıma animasyonu -%20 hız | 20 | *"Hızlıyız, daha da hızlı"* |
| Wider Strokes | 500 | 1 tıklama +2 alan | 15 | *"Büyük düşün, geniş kazı"* |
| Diamond Hands | 5K | 1 tıklama +3 alan | 10 | *"💎🙌 Asla bırakma"* |
| Pump It Up | 50K | 1 tıklama +5 alan | 10 | *"Pompalıyoruz!"* |
| GIGACHAD Scratch | 500K | Tüm bilet tek tıkla | 5 | *"Chad kazımacı"* |

### Eşleşme Yükseltmeleri (Daha çok coin/bilet)
| Yükseltme | Baz Maliyet | Etki | Max Svy | Flavor |
|-----------|------------|------|---------|--------|
| Lucky Charm | 50 | Eşleşme ödülü +%25 | 30 | *"Şans cesurları sever"* |
| Double or Nothing | 200 | %10 şansla ödül x2 | 20 | *"Risk = Ödül"* |
| Ticket Guru | 1K | Eşleşme ödülü +%50 | 20 | *"Bu işin uzmanıyız"* |
| Golden Touch | 5K | 3+ eşleşme ödülü x2 | 10 | *"Midas'ın torunu"* |
| YOLO Ticket | 50K | %1 şansla ödül x100 | 10 | *"You Only Live Once"* |
| Jackpot Hunter | 500K | Tüm eşleşme ödülü x3 | 5 | *"Büyük avın peşinde"* |

### Şans Yükseltmeleri (Daha iyi eşleşme/sinerji şansı)
| Yükseltme | Baz Maliyet | Etki | Max Svy | Flavor |
|-----------|------------|------|---------|--------|
| Gut Feeling | 100 | Eşleşme şansı +%5 | 20 | *"İçgüdülerine güven"* |
| Sinerji Radarı | 1K | Sinerji şansı +%10 | 15 | *"Combo seziyorum..."* |
| Joker Magnet | 10K | Joker sembol şansı x2 | 10 | *"🃏 Gel buraya"* |
| RNG Manipulator | 100K | Özel sembol şansı x2 | 5 | *"Evreni manipüle et"* |

---

## Pasif Gelir Kaynakları (Buildings)

Otomatik bilet tamamlayan yapılar. Cookie Clicker'ın "Grandma, Farm, Mine" sistemi.
Her building saniyede belirli miktarda bilet tamamlar ve eşleşme sonuçlarına göre coin kazandırır.

**Basitleştirilmiş:** Her building "BPS" (Bilet Per Second) üretir. Her bilet ortalama eşleşme ödülü kadar coin verir.

| Building | Baz Maliyet | BPS | Flavor |
|----------|------------|-----|--------|
| Oto-Kazıyıcı | 5K | 0.1 | *"Yavaş ama sadık"* |
| Mini Tezgah | 15K | 0.3 | *"Köşe başı tezgahı"* |
| Şans Makinesi | 50K | 1 | *"Insert coin to play"* |
| Kazıma Atölyesi | 150K | 3 | *"Zanaatkâr kalitesi"* |
| Bilet Fabrikası | 500K | 10 | *"Endüstriyel devrim"* |
| Şans Tapınağı | 2M | 30 | *"Şans tanrıları memnun"* |
| Kripto Madeni | 8M | 100 | *"Mining ama kazı kazan"* |
| Ay Üssü | 30M | 300 | *"TO THE MOON! 🚀"* |
| Paralel Evren | 100M | 1K | *"Sonsuz bilette sonsuz kazanç"* |
| Kara Delik | 500M | 5K | *"Tüm coin'leri çeker"* |

**Maliyet formülü:** `baz_maliyet * (1.15 ^ sahip_olunan)`
Her building birden fazla satın alınabilir.
Building'ler mevcut seçili bilet türünü kazır (daha iyi bilet = daha yüksek ortalama ödül).

---

## Çalışan Sistemi (Geç Oyun)

Building gibi çalışır - **maaş yok**, al ve unut. Farkı: çalışanlar **yüksek tier biletleri** otomatik kazır.

| Çalışan | Maliyet | Etki | Flavor |
|---------|---------|------|--------|
| Stajyer | 1M | Kağıt/Bronz bilet BPS +1 | *"Bedava çay yeter"* |
| Kazıyıcı | 5M | Gümüş bilet BPS +1 | *"İşini bilir"* |
| Usta | 25M | Altın bilet BPS +1 | *"20 yıllık deneyim"* |
| Profesyonel | 100M | Platin bilet BPS +0.5 | *"MBA mezunu"* |
| Whale | 500M | Elmas bilet BPS +0.2 | *"Parayı sever 🐋"* |

Birden fazla aynı çalışan tutulabilir.

---

## Rastgele Olaylar

Beklenmedik anlarda dopamin patlaması. Cookie Clicker'ın "Golden Cookie" sistemi.

### Altın Bilet ✨
- 45-120 saniyede bir ekranda parlayan altın bilet belirir
- Tıklarsan: 3 ödülden birini seç (aşağıda)
- Kaçırırsan: 10 saniye sonra kaybolur (FOMO)

### Bull Run! 🐂
- Rastgele: "BULL RUN! 30 saniye tüm kazanç x3!"
- Ekran yeşile döner, aktif kazıma büyük bonus

### Bear Market 🐻
- Nadir: "Bilet fiyatları 15 saniye -%50! BUY THE DIP!"
- Ucuza bilet stokla fırsatı

### Mega Jackpot Bileti 🌟
- Çok nadir (%0.1): Normal bilet yerine mega bilet çıkar
- Garanti yüksek eşleşme + büyük ödül

### Whale Alert 🐋
- Geç oyun: "Bir WHALE hesabına 1M coin yatırdı!"
- 60 saniye tüm pasif gelir x10

---

## "3'ten 1 Seç" Ödül Sistemi

Bazı anlarda oyuncuya 3 ödülden birini seçme şansı verilir.
Build tanımlamaz, sadece anlık bonus.

### Tetiklenme Anları
- **Altın Bilet** tıklandığında
- **Milestone** ödüllerinde
- **Her 100. bilette** (nadir bonus bilet)
- **Prestige** sırasında (birkaç kez)

### Örnek Seçimler
```
┌─────────────────────────────────────────┐
│         🎁 ÖDÜL SEÇ! (1/3)             │
│                                         │
│  [💰 500 Coin]  [⚡ 30sn x3]  [🎫 5    │
│                                Ücretsiz │
│                                Bilet]   │
│                                         │
└─────────────────────────────────────────┘
```

Seçenekler mevcut ilerleme durumuna göre ölçeklenir.

---

## İlerleme Aşamaları

### AŞAMA 1: Fakir Başlangıç (0 - 500 Coin)
*"İlk adım... WAGMI"*
- Ücretsiz kağıt biletler, 6 alan, 3 sembol
- 1 tıklama = 1 alan, bilet başına 6 tıklama
- İlk eşleşmeler, ilk sinerji keşfi (Meyve Kokteyli)
- İlk yükseltmeler: Paper Hands, Lucky Charm, Gut Feeling

### AŞAMA 2: Hızlanma (500 - 5K Coin)
*"Bronza geçtik, artık ciddiyiz"*
- Bronz bilet açılır (8 alan, 5 sembol, daha büyük ödüller)
- Kazıma hızı yükseltmeleri devreye girer (1 tıkla = 2 alan)
- Eşleşme bonusu artışları
- Gece Gökyüzü sinerjisi keşfedilebilir

### AŞAMA 3: Oto-Kazıyıcı! (5K - 50K Coin)
*"Eller serbest, para akmaya devam"*
- Gümüş bilet açılır
- **İlk building: Oto-Kazıyıcı!** Dönüm noktası!
- Artık AFK'da da bilet tamamlanıyor
- Oyuncu hâlâ elle kazıyarak daha hızlı ilerleyebilir
- *"Eskiden elle kazıyordum, artık makine kazıyor"*

### AŞAMA 4: Büyüme Patlaması (50K - 500K Coin)
*"Sayılar uçuyor, TO THE MOON! 🚀"*
- Altın bilet açılır (9 sembol, güçlü sinerjiler)
- Birden fazla building
- Lucky Seven ve Kraliyet sinerjileri mümkün
- Sayılar hızla büyüyor

### AŞAMA 5: İmparatorluk (500K - 10M Coin)
*"Artık patron biziz"*
- Platin bilet, çalışanlar açılır
- Gelişmiş buildings
- Ejderha Ateşi sinerjisi mümkün
- Pasif gelir elle kazımayı geçmeye başlıyor

### AŞAMA 6: Prestige (10M+ Coin)
*"Roket kalkıyor... 🚀🌙"*
- Prestige mümkün olur
- Kalıcı bonuslarla yeniden başla
- Her prestige daha hızlı ilerleme
- Sonsuz döngü başlar

---

## Koleksiyon Sistemi

Biletlerden rastgele koleksiyon parçaları düşer. Set tamamlama = kalıcı bonus (prestige'den etkilenmez).

| Set | Parçalar | Bonus | Flavor |
|-----|----------|-------|--------|
| Meyve Seti | Kiraz + Limon + Üzüm + Karpuz | Eşleşme ödülü +%15 | *"Sağlıklı kazanç"* |
| Değerli Taşlar | Yakut + Zümrüt + Safir + Elmas | Özel sembol şansı +%20 | *"Taşlar konuşuyor"* |
| Şanslı 7'ler | 7 (Kırmızı, Mavi, Yeşil, Altın) | Jackpot ödülü +%25 | *"Yedilerin gücü"* |
| Kripto Set | Bitcoin + Ethereum + Doge + Rocket | BPS +%30 | *"HODL forever"* |
| Kozmik | Yıldız + Ay + Güneş + Galaksi | Tüm ödüller +%20 | *"Evren bizimle"* |
| Meme Lords | Doge + Pepe + Moon + Lambo | Rastgele olay sıklığı +%25 | *"Internet kültürü"* |

---

## Milestone Ödülleri

Toplam kazanılan coin'e göre tek seferlik ödüller. Her milestone'da **3'ten 1 seç**.

| Milestone | Seçenekler (örnek) | Mesaj |
|-----------|-------------------|-------|
| 100 Coin | 50 Coin / 3 Ücretsiz Bilet / Eşleşme +%5 | *"İlk adım! 🎉"* |
| 1K Coin | 200 Coin / Kazıma hızı +1 / Sinerji ipucu | *"Binlere ulaştık!"* |
| 10K Coin | 2K Coin / Özel bilet / Eşleşme +%10 | *"Beş haneli! 📈"* |
| 100K Coin | 20K Coin / Nadir koleksiyon / BPS +%20 | *"PUMP IT! 🔥"* |
| 1M Coin | 200K Coin / Mega bilet / Tüm ödül +%15 | *"MİLYONER! 🎩"* |
| 10M Coin | 2M Coin / Prestige bonusu / BPS x2 (1dk) | *"Roket hazır 🚀"* |
| 100M Coin | Mega ödül paketi | *"WHALE STATUS! 🐋"* |
| 1B Coin | Efsanevi ödül | *"Wen Lambo? NOW! 🏎️"* |

---

## Prestige Sistemi - "TO THE MOON 🚀"

### Temel Mekanik
- Açılma: 10M+ toplam kazanılmış coin
- **Şans Yıldızı** formülü: `floor(sqrt(toplam_coin / 1M))`
- Sıfırlanan: Coin, yükseltmeler, buildings, çalışanlar
- Kalan: Koleksiyonlar, sinerji albümü, başarımlar, istatistikler, prestige bonusları

### Prestige Mağazası (Düz Liste)
Şans Yıldızları ile satın alınır. Dal/ağaç yok, istediğini al.

| Bonus | Maliyet | Etki |
|-------|---------|------|
| Başlangıç Sermayesi | 1 ⭐ | 500 coin ile başla |
| Hızlı Parmaklar | 1 ⭐ | Kazıma hızı +1 alan (kalıcı) |
| Şans Artışı | 2 ⭐ | Eşleşme şansı +%10 (kalıcı) |
| Bronz Erişim | 2 ⭐ | Bronz bilet baştan açık |
| Eşleşme Bonusu | 3 ⭐ | Tüm eşleşme ödülü +%25 (kalıcı) |
| Sinerji Sezgisi | 3 ⭐ | Sinerji şansı +%20 (kalıcı) |
| Hızlı Açılım | 5 ⭐ | İlk building -%50 ucuz |
| Altın Bilet Çağrısı | 5 ⭐ | Rastgele olay sıklığı +%50 |
| Oto-Kazıyıcı Başlangıç | 8 ⭐ | Oto-kazıyıcı ile başla |
| Joker Dostu | 10 ⭐ | Joker sembol şansı x2 (kalıcı) |
| CPS Boost | 10 ⭐ | Tüm BPS +%50 (kalıcı) |
| MONEY PRINTER | 25 ⭐ | Tüm kazanç x2 (kalıcı) |
| DIAMOND HANDS | 25 ⭐ | Tüm kazıma hızı x2 (kalıcı) |
| TO THE MOON | 50 ⭐ | Tüm kazanç x5 (kalıcı) |

Prestige sırasında da birkaç kez **3'ten 1 seç** bonus ekranı çıkar.

---

## Başarım Sistemi (Steam Achievements)

### Erken Oyun
| Başarım | Koşul | Flavor |
|---------|-------|--------|
| İlk Kazıma | 1 bilet tamamla | *"Yolculuk başlıyor"* |
| First Blood | İlk eşleşme | *"Kan kokusu... yani coin"* |
| Baby Steps | 100 coin kazan | *"Küçük adımlar"* |
| Sinerji Avcısı | İlk sinerji keşfet | *"Aha! Anı"* |
| HODL | 1K coin biriktir (harcamadan) | *"💎🙌"* |

### Orta Oyun
| Başarım | Koşul | Flavor |
|---------|-------|--------|
| Oto Pilot | İlk building al | *"Eller serbest"* |
| Combo Master | 5 farklı sinerji keşfet | *"Combo uzmanı"* |
| Bull Runner | 10 Bull Run olayı yakala | *"Boğayı yakala"* |
| Koleksiyoncu | İlk seti tamamla | *"Gotta catch 'em all"* |
| Altın Çağ | Altın bilete eriş | *"Parlıyoruz"* |

### Geç Oyun
| Başarım | Koşul | Flavor |
|---------|-------|--------|
| İlk Çalışan | İlk çalışanı tut | *"Patron oldum"* |
| Milyoner | 1M coin kazan | *"Mo money mo problems"* |
| To The Moon | İlk prestige yap | *"🚀🌙"* |
| Tüm Sinerjiler | Tüm sinerjileri keşfet | *"Matrix'i gördüm"* |
| Diamond Collector | Tüm koleksiyonları tamamla | *"Tam set"* |

### Gizli Başarımlar
| Başarım | Koşul | Flavor |
|---------|-------|--------|
| ??? | 3x Joker aynı bilette | *"Palyaço fiesta"* |
| ??? | 10 prestige yap | *"Döngünün efendisi"* |
| ??? | 1B coin kazan (tek run) | *"GIGAWHALE"* |
| ??? | Bear Market'te 50 bilet al | *"Gerçek dip alıcısı"* |

Toplam: 40+ başarım (genişletilebilir)

---

## İstatistik Ekranı

| Kategori | Veriler |
|----------|---------|
| Genel | Toplam coin (tüm zamanlar), toplam bilet, oynama süresi, prestige sayısı |
| Eşleşme | En büyük tek bilet kazancı, jackpot sayısı, eşleşme oranı |
| Sinerji | Keşfedilen / toplam, en çok tetiklenen, en kârlı |
| Bilet | Her türden kaç tane kazındı, ortalama kazanç |

---

## Offline Gelir

Oyuna geri dönüldüğünde:
```
┌──────────────────────────────────┐
│     ☀️ HOŞ GELDİN GERİ!         │
│                                  │
│   ⏰ 3 saat 24 dakika uzaktaydın │
│   🎫 Bilet kazındı: 127          │
│   💰 Kazancın: 45,230 Coin       │
│                                  │
│        [ TOPLA! ]                │
│                                  │
│  "Makine çalıştı, sen yokken    │
│   de para aktı!" 💵              │
└──────────────────────────────────┘
```

**Formül:** `offline_süre * BPS * ortalama_bilet_ödülü * 0.5`
(Aktif oynamanın yarısı kadar. Yükseltmeyle artırılabilir.)

---

## Ekran Tasarımı

### Ana Ekran Düzeni
```
┌─────────────────────────────────────────────┐
│ 💰 1,234 Coin  |  BPS: 0.3/sn  |  ⭐ 3    │  ← UI (Control)
├──────────┬──────────────────┬───────────────┤
│          │                  │               │
│ BİLET    │   AKTİF BİLET   │ YÜKSELTMELER  │
│ SEÇİMİ   │                  │               │
│          │ [███] [🍒] [███] │ Paper Hands ↑ │  ← UI (Control)
│ [Kağıt]  │ [███] [███] [🍋] │ Lucky Charm ↑ │
│ [Bronz]  │      ↑           │ Gut Feeling ↑ │
│  🔒       │  2D Obje         │               │
│  🔒       │  (Node2D)       │ ─────────────  │
│          │                  │ BUILDINGS      │
│  ↑       │                  │ Oto-Kazıyıcı 🔒│  ← UI (Control)
│ UI       │                  │ Mini Tezgah 🔒 │
├──────────┴──────────────────┴───────────────┤
│ [📊Stats] [📖Sinerji] [👥Çalışan🔒] [🚀Moon🔒] │  ← UI (Control)
└─────────────────────────────────────────────┘
```

### 2D Obje vs UI Ayrımı

Oyun iki katmandan oluşur:

**2D Objeler (Node2D) - Oyun Alanı:**
- Bilet (Sprite2D + tıklanabilir alanlar)
- Kazıma alanları (her alan ayrı 2D obje, tıklayınca kazınma shader'ı)
- Semboller (Sprite2D + açılma/parıltı animasyonu)
- Coin uçma efekti (Node2D serbest hareket)
- Konfeti / pırıltı / patlama (GPUParticles2D)
- Altın bilet olayı (ekranda beliren 2D obje)

**UI Elemanları (Control) - Arayüz:**
- Üst bar: Coin sayısı, BPS, Prestige yıldızları
- Sol panel: Bilet seçimi listesi
- Sağ panel: Yükseltmeler, Buildings, Çalışanlar
- Alt bar: Stats, Sinerji albümü, Prestige butonları
- Popup'lar: 3'ten 1 seç, milestone ödülü, offline gelir

Bu ayrım sayesinde bilet ve kazıma **oyun gibi hissediyor**, menüler ise temiz ve işlevsel kalıyor.

### Görsel Stil
- Parlak, canlı renkler (neon yeşil, altın, mor)
- Neon casino estetiği + kripto meme ikonları
- Kazıma efekti: Metalik gri alan, tıklayınca shader ile "kazınma" animasyonu (2D)
- Sembol açılma: Sprite animasyonu + Tween ile büyüme/parıltı (2D)
- Eşleşme bulundu: Eşleşen semboller parlar + coin sayısı havada uçar (2D)
- Sinerji keşfi: Ekran titremesi + GPUParticles2D patlama efekti + ses (2D)
- Jackpot: GPUParticles2D konfeti yağmuru + "JACKPOT!" yazısı + ekran flaş (2D)
- Bull Run: Ekran yeşile döner + boğa ikonu (2D)
- Sayı artışı: Tween ile yumuşak geçiş (UI)
- Buton hover/press: Tween ile büyüme efekti (UI)

---

## Save Sistemi

### Katmanlı Kayıt (Güvenlik Öncelikli)
1. **Otomatik:** Her 30 saniyede `save_main.json`
2. **Yedek:** Her 5 dakikada `save_backup.json`
3. **Çıkış:** Kapanırken `save_emergency.json`
4. **Steam Cloud:** Mümkün olduğunda
- Biri bozulursa diğerinden yükle

### Kayıt Edilen Veriler
Coin, yükseltmeler, buildings, çalışanlar, koleksiyonlar, sinerjiler, başarımlar, istatistikler, prestige verileri, son çıkış zamanı

---

## Teknik Notlar

### Motor & Ayarlar
- Godot 4.x, GDScript
- 2D render (Compatibility renderer)
- Hedef FPS: 60
- Min çözünürlük: 1280x720

### Mimari
- **2D Objeler (Node2D):** Bilet, kazıma alanları, semboller, efektler
- **UI (Control):** Üst bar, yan paneller, popup'lar
- **Autoload:** Oyun durumu (GameState), save sistemi (SaveManager)

### Kod ile Yapılacaklar (AI tarafından)
- Tüm oyun mekaniği ve matematik
- Tween animasyonları (sayı artışı, büyüme, fade, kayma, zıplama)
- GPUParticles2D efektleri (konfeti, pırıltı, coin yağmuru)
- Kazıma shader'ı (metalik katmanın silinmesi)
- Parlaklık/renk geçiş shader'ları
- Ses sistemi (doğru yerde doğru sesi çalma)
- Büyük sayı formatı: 1K, 1M, 1B, 1T, 1Qa, 1Qi...
- Maliyet formülü: `baz * 1.15^seviye`
- Olasılık sistemi (şeffaf, hesaplama oyuncuya gösterilir)
- Save/load sistemi (JSON)
- Offline gelir hesabı

### Dışarıdan Gerekli Asset'ler
- **Sembol görselleri:** Kiraz, limon, üzüm vb. (AI image generation ile üretilecek)
- **Ses efektleri:** Kazıma, coin, jackpot, sinerji sesleri (ücretsiz kaynak veya AI üretimi)
- **Müzik:** Arka plan müziği (ücretsiz kaynak veya AI üretimi)
- **Font:** Casino/meme tarzı font (ücretsiz font kaynağından)
