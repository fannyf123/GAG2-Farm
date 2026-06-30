# GAG2 Auto Farm - Tutorial Lengkap

> Panduan lengkap dari nol sampai script berjalan sempurna

---

## Daftar Isi

- [Persiapan](#persiapan)
- [Langkah 1: Buat Akun Roblox](#langkah-1-buat-akun-roblox)
- [Langkah 2: Install Executor](#langkah-2-install-executor)
- [Langkah 3: Setup Script](#langkah-3-setup-script)
- [Langkah 4: Jalankan Script](#langkah-4-jalankan-script)
- [Langkah 5: Multi-Bot (10+ Akun)](#langkah-5-multi-bot-10-akun)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)

---

## Persiapan

Sebelum mulai, siapkan hal berikut:

| Kebutuhan | Keterangan |
|-----------|------------|
| **HP Android** | RAM 4GB+ (8GB untuk multi-bot) |
| **Koneksi Internet** | Stabil, 5 Mbps+ |
| **Akun Roblox** | 1 akun per bot |
| **Executor** | Delta, Arceus X, atau Codex |

---

## Langkah 1: Buat Akun Roblox

### 1.1 Buat Akun Utama

1. Buka https://www.roblox.com/
2. Klik **Sign Up**
3. Isi data:
   - Username: `NamaAnda`
   - Password: `PasswordKuat123!`
   - Tanggal lahir
4. Klik **Sign Up**
5. Verifikasi email

### 1.2 Buat Akun Bot (Untuk Multi-Bot)

Ulangi langkah di atas untuk setiap bot yang ingin Anda buat.

**Tips:**
- Gunakan email berbeda untuk setiap akun
- Catat username dan password di tempat aman
- Jangan gunakan akun utama untuk bot

---

## Langkah 2: Install Executor

### 2.1 Download Delta Executor

1. Buka browser di HP
2. Kunjungi: https://delta-executor.com/
3. Klik **Download**
4. Tunggu download selesai

### 2.2 Install Delta

1. Buka file APK yang sudah didownload
2. Klik **Install**
3. Jika muncul peringatan "Unknown Source":
   - Buka **Settings** → **Security**
   - Aktifkan **Unknown Sources**
4. Tunggu install selesai

### 2.3 Get Key Delta

1. Buka Delta Executor
2. Klik **Get Key**
3. Akan muncul link shortener
4. **Copy link** tersebut
5. Buka https://izen.lol/ (Zen Bypass)
6. Paste link → Klik **Bypass**
7. Selesaikan captcha
8. **Copy key** yang muncul (contoh: `FREE_62a6863f...`)
9. Paste key di Delta
10. Klik **Submit**

**Delta sekarang aktif selama 24 jam.**

---

## Langkah 3: Setup Script

### 3.1 Buat Folder Auto-Execute

1. Buka **File Manager** di HP
2. Buka folder `/storage/emulated/0/`
3. Cari folder **Delta**
4. Di dalam folder Delta, cari folder **Autoexecute**
5. Jika tidak ada, buat folder baru:
   - Klik **New Folder**
   - Beri nama `Autoexecute`

### 3.2 Buat File Script

1. Di folder `Autoexecute`, buat file baru:
   - Klik **New File**
   - Beri nama `gag2farm.lua`

2. Buka file tersebut dengan text editor

3. Copy-paste kode berikut:

```lua
-- ============================================
-- GAG2 Auto Farm - Delta Auto-Execute
-- ============================================

-- Cek apakah game adalah GAG2
if game.PlaceId ~= 5765122481 then
    return
end

-- Tunggu game loading
repeat task.wait() until game:IsLoaded()
task.wait(5)

-- Load script utama
loadstring(game:HttpGet("https://raw.githubusercontent.com/fannyf123/GAG2-Farm/main/main.lua"))()
```

4. **Save** file

### 3.3 Aktifkan Auto-Execute di Delta

1. Buka Delta Executor
2. Buka **Settings**
3. Cari opsi **Auto Execute** atau **Autoexec**
4. Pastikan **ENABLED**

---

## Langkah 4: Jalankan Script

### 4.1 Buka Roblox

1. Buka aplikasi **Roblox**
2. Login dengan akun bot (bukan akun utama)

### 4.2 Join Game GAG2

1. Cari **"Grow a Garden 2"** di Roblox
2. Atau buka langsung: https://www.roblox.com/games/97598239454123/Grow-a-Garden-2
3. Klik **Play**

### 4.3 Script Otomatis Jalan

Setelah game loading:
1. Script akan otomatis dimuat
2. Tunggu beberapa detik
3. Script akan mulai:
   - Auto harvest tanaman
   - Auto plant bibit
   - Auto sell hasil panen
   - Auto beli gear/pet
   - Auto kirim mail

### 4.4 Cek Status

Script akan menampilkan log di console:

```
[*] GAG2 Auto Farm v1.0.0
[*] Loading config...
[*] Loading modules...
[*] All modules loaded!
[*] Starting main farm loop...
[12:34:56][HARVEST] Harvested 5 plants
[12:34:57][SELL] Sold all items
[12:34:58][PLANT] Planted 3 seeds
```

### 4.5 Quick Commands

Setelah script jalan, Anda bisa gunakan command ini di console:

```lua
_G.GAG.start()    -- Start farm
_G.GAG.stop()     -- Stop farm
_G.GAG.toggle()   -- Toggle farm
_G.GAG.sell()     -- Sell all items
_G.GAG.harvest()  -- Harvest all plants
_G.GAG.stats()    -- Show stats
```

---

## Langkah 5: Multi-Bot (10+ Akun)

### 5.1 Opsi A: VMOS Pro (HP RAM 8GB+)

#### Install VMOS Pro

1. Download VMOS Pro: https://www.vmos.com/
2. Install di HP
3. Buka VMOS Pro
4. Buat VM baru (Android 10)

#### Setup Setiap VM

Untuk setiap VM:

1. Buka **Play Store** di VM
2. Install **Roblox**
3. Install **Delta Executor**
4. Login akun bot
5. Setup script (Langkah 3)
6. Join GAG2

#### Struktur

```
HP Anda
├── VMOS VM 1 (Bot 1 + Delta + Script)
├── VMOS VM 2 (Bot 2 + Delta + Script)
├── VMOS VM 3 (Bot 3 + Delta + Script)
└── VMOS VM 4 (Bot 4 + Delta + Script)
```

### 5.2 Opsi B: Cloud Phone (Tanpa HP)

#### Beli Cloud Phone

| Provider | Harga/bulan | Link |
|----------|-------------|------|
| **Red Finger** | $3-5 | https://www.redfinger.com/ |
| **LDCloud** | $2-4 | https://www.ldcloud.com/ |
| **CloudMoon** | $3-5 | https://www.cloudmoon.com/ |

#### Setup Cloud Phone

Untuk setiap cloud phone:

1. Buka cloud phone
2. Install **Roblox** dari Play Store
3. Install **Delta Executor**
4. Login akun bot
5. Setup script (Langkah 3)
6. Join GAG2

### 5.3 Opsi C: Optimizer (Hemat Resource)

Untuk HP dengan RAM terbatas, gunakan optimizer:

#### Edit Script Auto-Execute

Ganti isi file `gag2farm.lua` dengan:

```lua
-- Cek game
if game.PlaceId ~= 5765122481 then
    return
end

-- Tunggu game load
repeat task.wait() until game:IsLoaded()
task.wait(5)

-- Optimizer
pcall(function() setfpscap(15) end)
pcall(function() game:GetService("RunService"):Set3dRenderingEnabled(false) end)

local Lighting = game:GetService("Lighting")
Lighting.GlobalShadows = false
Lighting.FogEnd = 0
Lighting.Brightness = 0

for _, effect in pairs(Lighting:GetDescendants()) do
    if effect:IsA("PostEffect") then effect:Destroy() end
end

for _, obj in pairs(workspace:GetDescendants()) do
    if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or
       obj:IsA("Sound") or obj:IsA("Decal") or obj:IsA("Texture") then
        obj:Destroy()
    end
end

spawn(function()
    while true do
        wait(30)
        collectgarbage("collect")
    end
end)

-- Load farm script
task.wait(2)
loadstring(game:HttpGet("https://raw.githubusercontent.com/fannyf123/GAG2-Farm/main/main.lua"))()
```

**Efek:** Grafis akan hilang, tapi script tetap jalan dan lebih ringan.

---

## Troubleshooting

### Script Tidak Jalan

| Masalah | Solusi |
|---------|--------|
| Script tidak muncul | Pastikan file di folder `Autoexecute` yang benar |
| Error loading | Cek koneksi internet |
| "Http requests not allowed" | Aktifkan http requests di executor settings |
| Game bukan GAG2 | Script hanya jalan di Place ID 5765122481 |

### Delta Tidak Bisa Dipakai

| Masalah | Solusi |
|---------|--------|
| Key expired | Get key baru (ulangi Langkah 2.3) |
| Key tidak work | Coba key baru atau pakai Zen Bypass |
| Delta crash | Update ke versi terbaru |
| HWID error | Key hanya work di 1 device |

### Script Error

| Masalah | Solusi |
|---------|--------|
| "attempt to index nil" | Tunggu game loading lebih lama |
| "Remote not found" | Nama remote mungkin berubah, perlu update script |
| Script berhenti | Restart game dan jalankan ulang |
| Crash | Kurangi FPS cap di config |

---

## FAQ

### T: Apakah script ini aman?

**A:** Script ini menggunakan RemoteEvents yang ada di game, bukan exploit. Tapi tetap ada risiko kecil terdeteksi.

### T: Apakah butuh root?

**A:** Tidak. Script ini jalan tanpa root.

### T: Berapa akun yang bisa dijalankan?

**A:** Tergantung RAM HP:
- 4GB RAM: 1-2 akun
- 8GB RAM: 3-5 akun (dengan optimizer)
- 12GB+ RAM: 5-10 akun

### T: Apakah bisa di PC?

**A:** Bisa, pakai emulator Android seperti BlueStacks atau LDPlayer.

### T: Bagaimana cara update script?

**A:** Script otomatis update dari GitHub. Tapi jika ada error, download ulang dari: https://github.com/fannyf123/GAG2-Farm

### T: Apakah butuh Delta?

**A:** Tidak harus. Bisa pakai executor lain:
- Arceus X (no key)
- Codex (no key)
- FluxusZ (no key)

### T: Berapa lama key Delta bertahan?

**A:** 24 jam. Setelah itu perlu get key baru.

### T: Apakah bisa auto-rejoin?

**A:** Belum ada fitur auto-rejoin di script ini. Tapi bisa ditambahkan.

---

## Link Penting

| Resource | Link |
|----------|------|
| **Script GAG2 Farm** | https://github.com/fannyf123/GAG2-Farm |
| **Delta Executor** | https://delta-executor.com/ |
| **Zen Bypass** | https://izen.lol/ |
| **VMOS Pro** | https://www.vmos.com/ |
| **GAG2 Game** | https://www.roblox.com/games/97598239454123/Grow-a-Garden-2 |

---

## Checklist

Sebelum mulai, pastikan:

- [ ] Sudah punya akun Roblox
- [ ] Sudah install executor (Delta/Arceus X/Codex)
- [ ] Sudah get key (jika pakai Delta)
- [ ] Sudah buat file script di folder autoexecute
- [ ] Sudah join game GAG2

---

## Update Terakhir

- **Tanggal:** 1 Juli 2026
- **Versi:** v1.0.0
- **Status:** Stable

---

Terakhir diperbarui: 1 Juli 2026
