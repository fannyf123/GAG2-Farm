# Quick Start - 7 Langkah

> Setup GAG2 Auto Farm di cloud phone + VMOS

---

## Langkah 1: Beli Cloud Phone

Buka https://www.redfinger.com/ → Beli cloud phone (RAM 8GB)

---

## Langkah 2: Install VMOS Pro

Buka browser di cloud phone → https://www.vmos.com/ → Download & Install

---

## Langkah 3: Buat 3 VM

Buka VMOS Pro → Add VM → Android 10, RAM 2GB → Ulangi 3x

---

## Langkah 4: Setup Setiap VM

Di setiap VM:
1. Play Store → Install Roblox
2. Install Delta Executor → Get Key
3. Login akun Roblox

---

## Langkah 5: Install Termux

Download: https://f-droid.org/repo/com.termux_1002.apk
Download: https://f-droid.org/repo/com.termux.boot_1000.apk

Buka Termux:
```bash
termux-setup-storage
pkg update && pkg upgrade && pkg install lua53
```

---

## Langkah 6: Jalankan Setup

```bash
cd /sdcard/Download
wget https://raw.githubusercontent.com/fannyf123/GAG2-Farm/main/setup-cloud-vmos.sh
chmod +x setup-cloud-vmos.sh
./setup-cloud-vmos.sh
```

---

## Langkah 7: Restart

Restart cloud phone. **Selesai!**

Semuanya otomatis:
- VMOS terbuka
- Semua VM terbuka
- Roblox jalan di setiap VM
- Script farming jalan

---

## Manual (Jika Diperlukan)

```bash
cd /sdcard/Download/gag2-cloud-vmos
./start.sh    # Start semua
./stop.sh     # Stop semua
./status.sh   # Cek status
```

---

## Estimasi

| Item | Biaya |
|------|-------|
| Cloud Phone | $3-5/bulan |
| VMOS Pro | Gratis |
| Delta Key | Gratis |
| **Total** | **$3-5/bulan** |

Untuk 3-5 bot!

---

Terakhir diperbarui: 1 Juli 2026
