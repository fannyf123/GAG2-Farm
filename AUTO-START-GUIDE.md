# GAG2 Auto-Start System

> Otomatis buka Roblox dan jalankan bot setelah cloud phone restart

---

## Apa Ini?

Sistem yang membuat cloud phone Anda otomatis:
1. Buka Roblox saat boot
2. Join game GAG2
3. Jalankan farming script
4. Monitor dan restart jika crash

**Anda tidak perlu setup ulang setelah restart!**

---

## Cara Kerja

```
Cloud Phone Restart
        ↓
Termux:Boot otomatis jalan
        ↓
Buka Roblox
        ↓
Join game GAG2
        ↓
Delta auto-execute farming script
        ↓
Bot berjalan otomatis!
```

---

## Installasi (1x saja)

### Langkah 1: Install Termux:Boot

1. Download: https://f-droid.org/repo/com.termux.boot_1000.apk
2. Install
3. Buka Termux:Boot sekali (untuk register)

### Langkah 2: Jalankan Setup

Di Termux:

```bash
cd /sdcard/Download
wget https://raw.githubusercontent.com/fannyf123/GAG2-Farm/main/setup-boot.sh
chmod +x setup-boot.sh
./setup-boot.sh
```

### Langkah 3: Restart

Restart cloud phone. Semuanya otomatis!

---

## File yang Dibuat

```
/sdcard/Download/gag2-auto-start/
├── auto-start.lua          # Auto-start script
├── gag2-all-in-one.lua     # Farming script
├── start.sh                # Start manual
├── stop.sh                 # Stop Roblox
├── restart.sh              # Restart
└── status.sh               # Cek status

~/.termux/boot/
└── gag2-auto-start.sh      # Boot script (otomatis)

/storage/emulated/0/Delta/Autoexecute/
└── gag2farm.lua            # Delta auto-execute
```

---

## Cara Pakai

### Otomatis (Setelah Setup)

1. Restart cloud phone
2. Tunggu 30-60 detik
3. Roblox otomatis buka
4. Game otomatis join
5. Script otomatis jalan
6. **Selesai!**

### Manual (Jika Diperlukan)

```bash
cd /sdcard/Download/gag2-auto-start

# Start
./start.sh

# Stop
./stop.sh

# Restart
./restart.sh

# Status
./status.sh
```

---

## Konfigurasi

Edit `auto-start.lua` untuk mengubah pengaturan:

```lua
local Config = {
    place_id = 5765122481,      -- GAG2 Place ID
    boot_delay = 30,            -- Delay setelah boot (detik)
    app_launch_delay = 10,      -- Delay setelah buka app
    game_load_delay = 20,       -- Delay setelah join game
    check_interval = 300,       -- Cek status setiap 5 menit
    restart_on_crash = true,    -- Restart jika crash
}
```

---

## FAQ

### T: Apakah ini aman?

**A:** Ya. Script hanya membuka Roblox dan menjalankan script farming. Tidak ada exploit atau cheat.

### T: Berapa lama delay setelah boot?

**A:** Default 30 detik. Bisa diubah di config.

### T: Apakah bisa untuk multi-bot?

**A:** Bisa. Jalankan `lua auto-start.lua boot` di setiap VMOS VM.

### T: Bagaimana jika Roblox crash?

**A:** Script akan otomatis restart Roblox setelah 5 menit.

### T: Apakah butuh root?

**A:** Tidak. Termux:Boot berjalan tanpa root.

---

## Troubleshooting

| Masalah | Solusi |
|---------|--------|
| **Tidak auto-start** | Pastikan Termux:Boot sudah diinstall dan dibuka sekali |
| **Roblox tidak buka** | Cek apakah Roblox terinstall |
| **Script tidak jalan** | Pastikan Delta terinstall dan auto-execute aktif |
| **Delay terlalu cepat** | Tambah `boot_delay` di config |

---

## Ringkasan

| Fitur | Status |
|-------|--------|
| Auto-start saat boot | ✅ |
| Auto-open Roblox | ✅ |
| Auto-join game | ✅ |
| Auto-run script | ✅ |
| Auto-restart jika crash | ✅ |
| Monitor & status | ✅ |
| Manual control | ✅ |

---

Terakhir diperbarui: 1 Juli 2026
