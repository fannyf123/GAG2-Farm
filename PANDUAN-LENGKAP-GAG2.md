# GAG2 Auto Farm - Panduan Lengkap Multi-Bot

## Daftar Isi

1. [Cara Kerja Script](#1-cara-kerja-script)
2. [Jalankan Banyak Roblox di 1 HP](#2-jalankan-banyak-roblox-di-1-hp)
3. [Setup 10+ Bot](#3-setup-10-bot)
4. [Spesifikasi yang Dibutuhkan](#4-spesifikasi-yang-dibutuhkan)
5. [Estimasi Biaya](#5-estimasi-biaya)
6. [Tips & Trik](#6-tips--trik)

---

## 1. Cara Kerja Script

### Apa yang Dilakukan Script?

Script GAG2 Auto Farm melakukan otomasi sebagai berikut:

| Fitur | Fungsi |
|-------|--------|
| **Auto Harvest** | Panen tanaman otomatis saat sudah matang |
| **Auto Plant** | Tanam bibit otomatis setelah panen |
| **Auto Sell** | Jual hasil panen saat inventory penuh |
| **Auto Expand** | Beli perluasan kebun otomatis |
| **Auto Pets** | Beli & equip pet otomatis |
| **Auto Gear** | Beli sprinkler & gear otomatis |
| **Auto Mail** | Kirim item ke akun utama |
| **Teleport** | Pindah lokasi dengan cepat |

### Alur Kerja

```
┌─────────────────────────────────────┐
│           Script Mulai              │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│         Cek Inventory               │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│    Harvest Tanaman yang Siap        │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│    Jual Jika Inventory Penuh        │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│        Tanam Bibit Baru             │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│    Beli Perluasan Jika Cukup Uang   │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│    Beli Pet & Gear                  │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│    Kirim Item ke Akun Utama         │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│        Ulangi dari Awal             │
└─────────────────────────────────────┘
```

---

## 2. Jalankan Banyak Roblox di 1 HP

### Apakah Bisa 1 HP Banyak Roblox?

**BISA!** Ada beberapa cara untuk menjalankan banyak Roblox di 1 HP:

### Cara 1: VMOS Pro (Paling Direkomendasikan)

VMOS adalah aplikasi **Virtual Machine** yang membuat HP Anda seolah-olah punya banyak HP di dalamnya.

#### Kelebihan VMOS

| Fitur | Keterangan |
|-------|------------|
| ✅ Bisa jalankan 2-5 Roblox | Tergantung RAM HP |
| ✅ Setiap VM terpisah | Setiap VM punya akun sendiri |
| ✅ Support root | Bisa install executor |
| ✅ Tidak terdeteksi anti-cheat | Karena dianggap device terpisah |

#### Spesifikasi HP untuk VMOS

| RAM HP | Jumlah VM (Roblox) |
|--------|---------------------|
| 4GB | 1-2 VM |
| 6GB | 2-3 VM |
| 8GB | 3-4 VM |
| 12GB | 4-6 VM |
| 16GB | 6-8 VM |

#### Cara Setup VMOS

1. **Download VMOS Pro**
   - Website: https://www.vmos.com/
   - Atau cari "VMOS Pro" di Google

2. **Install VMOS Pro** di HP Anda

3. **Buat VM Baru**
   - Buka VMOS Pro
   - Klik "Add VM"
   - Pilih Android 7.1 atau 10
   - Tunggu proses selesai

4. **Setup di Setiap VM**
   - Buka Play Store di VM
   - Install Roblox
   - Install Delta Executor
   - Login akun Roblox
   - Setup script auto-farm

5. **Ulangi untuk Setiap VM**
   - Buat VM baru untuk setiap bot
   - Setup dengan akun berbeda

#### Struktur di VMOS

```
HP Anda (Host)
├── VMOS VM 1 (Android 10)
│   ├── Roblox (Akun Bot 1)
│   ├── Delta Executor
│   └── Script GAG2 Farm
│
├── VMOS VM 2 (Android 10)
│   ├── Roblox (Akun Bot 2)
│   ├── Delta Executor
│   └── Script GAG2 Farm
│
├── VMOS VM 3 (Android 10)
│   ├── Roblox (Akun Bot 3)
│   ├── Delta Executor
│   └── Script GAG2 Farm
│
└── ... (tergantung RAM)
```

---

### Cara 2: Multi-Parallel / Dual Space

Aplikasi **clone** yang bisa jalankan beberapa Roblox sekaligus.

#### Aplikasi yang Tersedia

| Aplikasi | Platform | Jumlah Clone |
|----------|----------|--------------|
| **Multi Parallel** | Android | 5+ |
| **Dual Space** | Android | 2 |
| **Parallel Space** | Android | 2-3 |
| **Island** | Android | 2 |
| **Shelter** | Android | 2 |

#### Kelebihan & Kekurangan

| Kelebihan | Kekurangan |
|-----------|------------|
| ✅ Lebih ringan dari VMOS | ❌ Kadang terdeteksi anti-cheat |
| ✅ Tidak butuh root | ❌ Tidak semua executor support |
| ✅ Mudah digunakan | ❌ Tidak stabil untuk banyak clone |

#### Cara Setup Multi-Parallel

1. **Download Multi Parallel** dari Play Store
2. **Buka Multi Parallel**
3. **Tambah Roblox** ke daftar clone
4. **Buka Roblox clone** → Login akun bot
5. **Install Delta** di clone
6. **Setup script** auto-farm
7. **Ulangi** untuk setiap clone

---

### Cara 3: Termux + proot-distro (Advanced)

Gunakan **Termux** untuk menjalankan banyak instance Linux yang masing-masing bisa jalankan Roblox.

#### Kelebihan

| Fitur | Keterangan |
|-------|------------|
| ✅ Bisa jalankan banyak instance | 5-10+ tergantung resource |
| ✅ Gratis | Tidak butuh bayar |
| ✅ Full kontrol | Bisa di-custom |

#### Kekurangan

| Kekurangan | Keterangan |
|------------|------------|
| ❌ Setup rumit | Butuh pengetahuan Linux |
| ❌ Butuh root | Untuk akses penuh |
| ❌ Performa kurang | Tidak secepat native |

#### Cara Setup Termux

```bash
# Install Termux
pkg install termux-api

# Install proot-distro
pkg install proot-distro

# Install Ubuntu
proot-distro install ubuntu

# Login ke Ubuntu
proot-distro login ubuntu

# Install dependencies
apt update && apt install -y wget curl

# Download & install Roblox (butuh cara khusus)
# (Ini memerlukan setup lebih lanjut)
```

---

### Perbandingan Metode

| Metode | Jumlah Instance | Kemudahan | Stabilitas | Root |
|--------|-----------------|-----------|------------|------|
| **VMOS Pro** | 2-5 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ✅ |
| **Multi Parallel** | 2-3 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ❌ |
| **Termux** | 5-10+ | ⭐⭐ | ⭐⭐ | ✅ |
| **Cloud Phone** | 1 per device | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ✅ |

---

## 3. Setup 10+ Bot

### Opsi A: VMOS + Cloud Phone (Hybrid)

Gabungkan VMOS dan Cloud Phone untuk hasil optimal:

```
HP Anda (8GB RAM)
├── VMOS VM 1 (Bot 1)
├── VMOS VM 2 (Bot 2)
├── VMOS VM 3 (Bot 3)
└── VMOS VM 4 (Bot 4)

Cloud Phone 1 (Bot 5)
Cloud Phone 2 (Bot 6)
Cloud Phone 3 (Bot 7)
Cloud Phone 4 (Bot 8)
Cloud Phone 5 (Bot 9)
Cloud Phone 6 (Bot 10)
Cloud Phone 7 (Akun Utama)
```

**Total:** 4 bot di VMOS + 6 bot di Cloud Phone + 1 akun utama = 11 akun

### Opsi B: Full Cloud Phone

```
Cloud Phone 1 (Bot 1)
Cloud Phone 2 (Bot 2)
Cloud Phone 3 (Bot 3)
...
Cloud Phone 10 (Bot 10)
Cloud Phone 11 (Akun Utama)
```

**Total:** 11 Cloud Phone

### Opsi C: Full VMOS (HP flagship)

```
HP 12GB+ RAM
├── VMOS VM 1 (Bot 1)
├── VMOS VM 2 (Bot 2)
├── VMOS VM 3 (Bot 3)
├── VMOS VM 4 (Bot 4)
├── VMOS VM 5 (Bot 5)
├── VMOS VM 6 (Bot 6)
├── VMOS VM 7 (Bot 7)
└── VMOS VM 8 (Bot 8 + Akun Utama)
```

**Total:** 8 bot di 1 HP (butuh RAM 16GB+)

---

## 4. Spesifikasi yang Dibutuhkan

### Spesifikasi per Instance Roblox

| Komponen | Minimum | Rekomendasi |
|----------|---------|-------------|
| **RAM** | 1.5GB | 2GB |
| **Storage** | 2GB | 4GB |
| **CPU** | 1 core | 2 core |
| **Internet** | 2 Mbps | 5 Mbps |

### Spesifikasi HP untuk VMOS

| Jumlah Bot | RAM HP | Storage HP | Contoh HP |
|------------|--------|------------|-----------|
| 2-3 bot | 6GB | 64GB | Samsung A54 |
| 4-5 bot | 8GB | 128GB | Samsung S23 |
| 6-8 bot | 12GB | 256GB | Samsung S24 Ultra |
| 8-10 bot | 16GB | 512GB | iPhone 15 Pro Max |

### Spesifikasi Cloud Phone

| Komponen | Minimum | Rekomendasi |
|----------|---------|-------------|
| **RAM** | 3GB | 4GB |
| **Storage** | 16GB | 32GB |
| **CPU** | 2 core | 4 core |
| **Android** | 8.0 | 10+ |

---

## 5. Estimasi Biaya

### Opsi A: VMOS + Cloud Phone (Hybrid)

| Komponen | Jumlah | Harga | Total |
|----------|--------|-------|-------|
| HP flagship (beli 1x) | 1 | $500 | $500 |
| Cloud Phone (per bulan) | 7 | $4 | $28/bulan |
| **Total Bulan 1** | | | **$528** |
| **Total per Bulan (setelah)** | | | **$28** |

### Opsi B: Full Cloud Phone

| Komponen | Jumlah | Harga | Total |
|----------|--------|-------|-------|
| Cloud Phone (per bulan) | 11 | $4 | $44/bulan |
| **Total per Bulan** | | | **$44** |

### Opsi C: Full VMOS (HP flagship)

| Komponen | Jumlah | Harga | Total |
|----------|--------|-------|-------|
| HP 16GB RAM (beli 1x) | 1 | $800 | $800 |
| **Total** | | | **$800** |

---

## 6. Tips & Trik

### Tips Hemat Resource

| Tips | Efek |
|------|------|
| **FPS Cap 15** | Hemat CPU & baterai 50% |
| **Low Graphics** | Hemat RAM 30% |
| **Remove Other Gardens** | Hemat RAM 20% |
| **Hide Crop Visuals** | Hemat GPU 40% |
| **Matikan UI** | Hemat resource 10% |

### Tips Menjaga Stabilitas

| Tips | Keterangan |
|------|------------|
| **Restart 1x/minggu** | Bersihkan memory leak |
| **Update script** | Fix bug & fitur baru |
| **Cek key Delta** | Perpanjang jika expired |
| **Monitor error** | Fix masalah segera |
| **Jangan terlalu banyak VM** | Sesuaikan dengan RAM |

### Tips Keamanan Akun

| Tips | Keterangan |
|------|------------|
| **Jangan main di akun bot** | Hanya untuk farming |
| **Jangan share info akun** | Lindungi data login |
| **Gunakan email terpisah** | Untuk setiap bot |
| **Verifikasi 2FA** | Jika tersedia |
| **Gunakan VPN** | Untuk keamanan tambahan |

### Tips Auto-Rejoin

Untuk menjaga bot tetap jalan meski disconnect:

```lua
-- Tambahkan di script
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

-- Auto rejoin saat disconnect
Players.LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.InProgress then
        -- Script akan auto-execute setelah teleport
    end
end)

-- Rejoin saat error/kick
game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    if child.Name == "ErrorPrompt" then
        task.wait(5)
        TeleportService:Teleport(5765122481) -- Place ID GAG2
    end
end)
```

---

## Ringkasan

| Aspek | Detail |
|-------|--------|
| **1 HP banyak Roblox?** | ✅ Bisa, pakai VMOS/Multi-Parallel |
| **Rekomendasi** | VMOS Pro untuk 2-5 bot per HP |
| **10+ bot** | Hybrid VMOS + Cloud Phone |
| **Biaya** | $28-44/bulan (hybrid) atau $800 (full VMOS) |
| **Script** | https://github.com/fannyf123/GAG2-Farm |
| **Executor** | Delta (auto-execute) |

---

## Link Penting

| Resource | Link |
|----------|------|
| **Script GAG2 Farm** | https://github.com/fannyf123/GAG2-Farm |
| **VMOS Pro** | https://www.vmos.com/ |
| **Delta Executor** | https://delta-executor.com/ |
| **Zen Bypass** | https://izen.lol/ |
| **Red Finger** | https://www.redfinger.com/ |
| **LDCloud** | https://www.ldcloud.com/ |

---

Terakhir diperbarui: 1 Juli 2026
