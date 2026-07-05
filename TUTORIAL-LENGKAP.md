# GAG2 Auto Farm - Tutorial Lengkap

> Dari nol sampai bot berjalan 24/7 otomatis

---

## Daftar Isi

- [Apa Ini?](#apa-ini)
- [Arsitektur Sistem](#arsitektur-sistem)
- [Kebutuhan](#kebutuhan)
- [Langkah 1: Beli Cloud Phone](#langkah-1-beli-cloud-phone)
- [Langkah 2: Install VMOS Pro](#langkah-2-install-vmos-pro)
- [Langkah 3: Buat VM di VMOS](#langkah-3-buat-vm-di-vmos)
- [Langkah 4: Setup Setiap VM](#langkah-4-setup-setiap-vm)
- [Langkah 5: Install Termux](#langkah-5-install-termux)
- [Langkah 6: Jalankan Setup](#langkah-6-jalankan-setup)
- [Langkah 7: Restart & Selesai](#langkah-7-restart--selesai)
- [Manual Control](#manual-control)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)

---

## Apa Ini?

Sistem otomatis untuk menjalankan **banyak bot GAG2** di **1 cloud phone** dengan **VMOS Pro**.

**Kelebihan:**
- ✅ **Hemat biaya**: 1 cloud phone ($3-5/bulan) untuk 3-5+ bot
- ✅ **24/7**: Cloud phone selalu hidup
- ✅ **Otomatis**: Semuanya jalan sendiri setelah restart
- ✅ **1x setup**: Tidak perlu setup ulang

---

## Arsitektur Sistem

```
Cloud Phone (1 biaya, 24/7)
└── Termux (Controller)
    └── VMOS Pro
        ├── VM 1 (Bot 1) → Roblox + Script
        ├── VM 2 (Bot 2) → Roblox + Script
        ├── VM 3 (Bot 3) → Roblox + Script
        └── ... (tergantung RAM)
```

---

## Kebutuhan

| Komponen | Keterangan |
|----------|------------|
| **Cloud Phone** | Red Finger, LDCloud, CloudMoon, dll |
| **Akun Roblox** | 1 akun per bot |
| **Akun Google** | Untuk Play Store di VMOS |

**Estimasi Biaya:**

| Item | Biaya |
|------|-------|
| Cloud Phone | $3-5/bulan |
| VMOS Pro | Gratis |
| Delta Key | Gratis (Zen Bypass) |
| **Total** | **$3-5/bulan** |

---

## Langkah 1: Beli Cloud Phone

### Pilih Provider

| Provider | Harga/bulan | Link |
|----------|-------------|------|
| **Red Finger** | $3-5 | https://www.redfinger.com/ |
| **LDCloud** | $2-4 | https://www.ldcloud.com/ |
| **CloudMoon** | $3-5 | https://www.cloudmoon.com/ |
| **OonDroid** | $2-4 | https://www.oondroid.com/ |

### Spesifikasi yang Dibutuhkan

| Komponen | Minimum | Rekomendasi |
|----------|---------|-------------|
| **RAM** | 4GB | 8GB |
| **Storage** | 32GB | 64GB |
| **Android** | 8.0 | 10+ |

**Catatan:** RAM 8GB bisa jalankan 3-5 VM.

### Cara Beli (Contoh: Red Finger)

1. Buka https://www.redfinger.com/
2. Daftar akun
3. Klik "Buy Device"
4. Pilih paket (disarankan RAM 8GB)
5. Bayar
6. Tunggu cloud phone aktif

---

## Langkah 2: Install VMOS Pro

### Download VMOS Pro

1. Buka browser di cloud phone
2. Kunjungi: https://www.vmos.com/
3. Download **VMOS Pro**
4. Install APK
5. Buka VMOS Pro
6. Tunggu loading pertama (2-5 menit)

### Verifikasi

Pastikan VMOS Pro sudah terbuka dan menampilkan halaman utama.

---

## Langkah 3: Buat VM di VMOS

### Buat VM Pertama

1. Buka VMOS Pro
2. Klik **"Add VM"** atau tombol **"+"**
3. Pilih pengaturan:
   - **Android Version:** 10
   - **RAM:** 2GB
   - **Storage:** 8GB
4. Klik **"Create"** atau **"Add"**
5. Tunggu proses selesai (5-10 menit)

### Buat VM Lainnya

Ulangi langkah di atas untuk membuat VM tambahan:

| RAM Cloud Phone | Jumlah VM | RAM per VM |
|-----------------|-----------|------------|
| 4GB | 1-2 VM | 2GB |
| 6GB | 2-3 VM | 2GB |
| 8GB | 3-5 VM | 2GB |
| 12GB | 5-8 VM | 2GB |

**Tips:** Jangan buat terlalu banyak VM. Sesuaikan dengan RAM cloud phone.

---

## Langkah 4: Setup Setiap VM

Untuk **setiap VM**, lakukan langkah berikut:

### 4.1 Buka VM

1. Klik VM yang sudah dibuat
2. Tunggu VM loading (1-2 menit)

### 4.2 Login Google

1. Buka **Play Store**
2. Login dengan akun Google
3. Jika tidak punya, buat akun baru

### 4.3 Install Roblox

1. Cari **"Roblox"** di Play Store
2. Klik **"Install"**
3. Tunggu install selesai

### 4.4 Install Delta Executor

1. Buka browser di VM
2. Download Delta: https://delta-executor.com/
3. Install APK
4. Buka Delta
5. **Get Key** (pakai Zen Bypass: https://izen.lol/)
6. Paste key
7. Delta aktif

### 4.5 Login Akun Roblox

1. Buka **Roblox**
2. Login dengan akun bot
3. Pastikan berhasil masuk

### 4.6 Ulangi untuk Setiap VM

Ulangi langkah 4.1 - 4.5 untuk setiap VM yang sudah dibuat.

---

## Langkah 5: Install Termux

### Download Termux

1. Buka browser di cloud phone
2. Download: https://f-droid.org/repo/com.termux_1002.apk
3. Install APK

### Install Termux:Boot

1. Download: https://f-droid.org/repo/com.termux.boot_1000.apk
2. Install APK
3. **Buka Termux:Boot sekali** (untuk register)

### Setup Termux

1. Buka **Termux**
2. Jalankan perintah berikut:

```bash
termux-setup-storage
pkg update && pkg upgrade
pkg install lua53 python git wget curl
```

---

## Langkah 6: Jalankan Setup

Di Termux, jalankan perintah berikut:

```bash
cd /sdcard/Download
wget https://raw.githubusercontent.com/fannyf123/GAG2-Farm/master/setup-cloud-vmos.sh
chmod +x setup-cloud-vmos.sh
./setup-cloud-vmos.sh
```

Script akan otomatis:
1. Install dependencies
2. Download scripts
3. Setup Termux:Boot
4. Buat control scripts

---

## Langkah 7: Restart & Selesai

### Restart Cloud Phone

1. Restart cloud phone
2. Tunggu 30-60 detik
3. Termux:Boot akan otomatis jalan
4. Script akan:
   - Buka VMOS
   - Buka setiap VM
   - Buka Roblox di setiap VM
   - Join game GAG2
   - Jalankan farming script

### Verifikasi

Setelah restart, cek apakah:
- [ ] VMOS sudah terbuka
- [ ] Setiap VM sudah terbuka
- [ ] Roblox sudah jalan di setiap VM
- [ ] Script sudah berjalan

---

## Manual Control

Jika perlu kontrol manual, buka Termux:

```bash
cd /sdcard/Download/gag2-cloud-vmos
```

### Perintah yang Tersedia

| Perintah | Fungsi |
|----------|--------|
| `./start.sh` | Start semua VM |
| `./stop.sh` | Stop semua VM |
| `./restart.sh` | Restart semua VM |
| `./status.sh` | Cek status |

### Atau Pakai Menu Interaktif

```bash
lua cloud-vmos-controller.lua
```

Akan muncul menu:

```
========================================
  MENU
========================================
  [1] Boot sequence (otomatis semua)
  [2] Start semua VM
  [3] Stop semua VM
  [4] Restart semua VM
  [5] Monitor loop
  [6] Status
  [7] Set jumlah VM
  [8] Setup Delta auto-execute
  [0] Exit
========================================
```

---

## Troubleshooting

### VMOS Tidak Muncul

| Masalah | Solusi |
|---------|--------|
| VMOS crash | Kurangi jumlah VM |
| VMOS lambat | Kurangi RAM per VM |
| VMOS tidak buka | Install ulang VMOS |

### Roblox Tidak Jalan

| Masalah | Solusi |
|---------|--------|
| Roblox crash | Update Roblox ke versi terbaru |
| Tidak bisa join game | Cek koneksi internet |
| Script tidak jalan | Pastikan Delta aktif |

### Script Error

| Masalah | Solusi |
|---------|--------|
| Script tidak muncul | Cek Delta auto-execute |
| Error loading | Cek koneksi internet |
| Script berhenti | Restart VM |

### Cloud Phone

| Masalah | Solusi |
|---------|--------|
| Tidak auto-start | Pastikan Termux:Boot terinstall |
| Lambat | Kurangi jumlah VM |
| Sering crash | Ganti provider cloud phone |

---

## FAQ

### T: Berapa bot yang bisa dijalankan?

**A:** Tergantung RAM cloud phone:
- 4GB: 1-2 bot
- 8GB: 3-5 bot
- 12GB: 5-8 bot

### T: Apakah butuh root?

**A:** Tidak. Semuanya berjalan tanpa root.

### T: Apakah aman?

**A:** Ya. Script hanya menjalankan farming otomatis. Tidak ada exploit.

### T: Berapa biaya per bulan?

**A:** $3-5/bulan untuk cloud phone. Semuanya gratis.

### T: Apakah bisa di HP sendiri (bukan cloud)?

**A:** Bisa. Tapi HP harus selalu hidup dan terhubung internet.

### T: Bagaimana cara menambah bot?

**A:** 
1. Buka VMOS Pro
2. Buat VM baru
3. Setup VM (Roblox + Delta + Login)
4. Restart cloud phone

### T: Bagaimana cara menghapus bot?

**A:**
1. Buka VMOS Pro
2. Hapus VM yang tidak diperlukan
3. Restart cloud phone

---

## Estimasi Biaya

| Setup | Biaya/bulan |
|-------|-------------|
| 1 Cloud Phone (3-5 bot) | $3-5 |
| 5 Cloud Phone (5 bot) | $20 |
| **Hemat dengan VMOS** | **$15-17** |

---

## Link Penting

| Resource | Link |
|----------|------|
| **Script GAG2 Farm** | https://github.com/fannyf123/GAG2-Farm |
| **Setup Script** | https://github.com/fannyf123/GAG2-Farm/blob/main/setup-cloud-vmos.sh |
| **VMOS Pro** | https://www.vmos.com/ |
| **Delta Executor** | https://delta-executor.com/ |
| **Zen Bypass** | https://izen.lol/ |
| **Termux** | https://f-droid.org/repo/com.termux_1002.apk |
| **Termux:Boot** | https://f-droid.org/repo/com.termux.boot_1000.apk |

---

## Checklist

Sebelum mulai, pastikan:

- [ ] Sudah beli cloud phone
- [ ] Sudah install VMOS Pro
- [ ] Sudah buat VM (3-5 VM)
- [ ] Sudah install Roblox di setiap VM
- [ ] Sudah install Delta di setiap VM
- [ ] Sudah login akun Roblox di setiap VM
- [ ] Sudah install Termux
- [ ] Sudah install Termux:Boot
- [ ] Sudah jalankan setup script
- [ ] Sudah restart cloud phone

---

## Update Terakhir

- **Tanggal:** 1 Juli 2026
- **Versi:** v1.0.0
- **Status:** Stable

---

Terakhir diperbarui: 1 Juli 2026
