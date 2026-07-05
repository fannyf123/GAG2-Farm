# VMOS + Termux Setup

> Setup VMOS di cloud phone untuk multi-bot GAG2

---

## Ringkasan

| Komponen | Fungsi |
|----------|--------|
| **Cloud Phone** | Tempat VMOS berjalan 24/7 |
| **VMOS Pro** | Menjalankan banyak VM Android |
| **Termux** | Controller otomatis |
| **Termux:Boot** | Auto-start saat boot |
| **Delta** | Executor untuk Roblox |

---

## Struktur Folder

```
Cloud Phone
├── /sdcard/Download/gag2-cloud-vmos/
│   ├── cloud-vmos-controller.lua    # Controller script
│   ├── gag2-all-in-one.lua          # Farming script
│   ├── start.sh                     # Start manual
│   ├── stop.sh                      # Stop manual
│   ├── restart.sh                   # Restart manual
│   └── status.sh                    # Cek status
│
├── ~/.termux/boot/
│   └── gag2-cloud-vmos.sh           # Auto-start script
│
└── VMOS Pro
    ├── VM 1 (Bot 1)
    │   └── /storage/emulated/0/Delta/Autoexecute/
    │       └── gag2farm.lua         # Auto-execute script
    ├── VM 2 (Bot 2)
    │   └── ...
    └── VM 3 (Bot 3)
        └── ...
```

---

## Setup Script (setup-cloud-vmos.sh)

Script ini melakukan:

1. **Install dependencies**
   ```bash
   pkg install lua53 python git wget curl termux-api
   ```

2. **Download scripts**
   ```bash
   cd /sdcard/Download/gag2-cloud-vmos
   wget cloud-vmos-controller.lua
   wget gag2-all-in-one.lua
   ```

3. **Setup Termux:Boot**
   ```bash
   mkdir -p ~/.termux/boot
   # Buat boot script
   ```

4. **Buat control scripts**
   ```bash
   # start.sh, stop.sh, restart.sh, status.sh
   ```

---

## Controller Script (cloud-vmos-controller.lua)

Script ini melakukan:

1. **Boot Sequence**
   - Tunggu 30 detik setelah boot
   - Buka VMOS Pro
   - Buka setiap VM
   - Buka Roblox di setiap VM
   - Join game GAG2
   - Inject farming script

2. **Monitor Loop**
   - Cek setiap 5 menit
   - Jika VMOS crash → restart
   - Jika Roblox crash → restart

3. **Manual Control**
   - Menu interaktif
   - Start/Stop/Restart

---

## Boot Script (~/.termux/boot/gag2-cloud-vmos.sh)

```bash
#!/bin/bash
# Auto-start saat boot

sleep 30  # Tunggu sistem stabil

cd /sdcard/Download/gag2-cloud-vmos
lua cloud-vmos-controller.lua boot
```

---

## Control Scripts

### start.sh
```bash
#!/bin/bash
cd /sdcard/Download/gag2-cloud-vmos
lua cloud-vmos-controller.lua start
```

### stop.sh
```bash
#!/bin/bash
am force-stop com.vmos.pro
am force-stop com.roblox.client
```

### restart.sh
```bash
#!/bin/bash
cd /sdcard/Download/gag2-cloud-vmos
lua cloud-vmos-controller.lua restart
```

### status.sh
```bash
#!/bin/bash
echo "VMOS: $(pidof com.vmos.pro > /dev/null && echo RUNNING || echo STOPPED)"
echo "Roblox: $(pidof com.roblox.client > /dev/null && echo RUNNING || echo STOPPED)"
```

---

## Auto-Execute Script (Di Setiap VM)

File: `/storage/emulated/0/Delta/Autoexecute/gag2farm.lua`

```lua
-- GAG2 Auto Farm
if game.PlaceId ~= 97598239454123 then
    return
end

repeat task.wait() until game:IsLoaded()
task.wait(5)

-- Optimizer
pcall(function() setfpscap(15) end)
pcall(function() game:GetService("RunService"):Set3dRenderingEnabled(false) end)

-- Load farm script
task.wait(2)
loadstring(game:HttpGet("https://raw.githubusercontent.com/fannyf123/GAG2-Farm/master/gag2-all-in-one.lua"))()
```

---

## Cara Kerja

```
1. Cloud Phone boot
           ↓
2. Termux:Boot jalan
           ↓
3. Jalankan cloud-vmos-controller.lua boot
           ↓
4. Buka VMOS Pro
           ↓
5. Buka VM 1 → Roblox → Join GAG2 → Script jalan
           ↓
6. Buka VM 2 → Roblox → Join GAG2 → Script jalan
           ↓
7. Buka VM 3 → Roblox → Join GAG2 → Script jalan
           ↓
8. Monitor setiap 5 menit
           ↓
9. Restart jika crash
```

---

## Konfigurasi

Edit `cloud-vmos-controller.lua`:

```lua
local Config = {
    num_vms = 3,              -- Jumlah VM
    place_id = 5765122481,    -- GAG2 Place ID
    boot_delay = 30,          -- Delay setelah boot
    vm_open_delay = 20,       -- Delay buka VM
    roblox_open_delay = 15,   -- Delay buka Roblox
    game_join_delay = 25,     -- Delay join game
    between_vm_delay = 10,    -- Delay antar VM
    check_interval = 300,     -- Cek setiap 5 menit
    restart_on_crash = true,  -- Restart jika crash
}
```

---

## Perintah Manual

```bash
cd /sdcard/Download/gag2-cloud-vmos

# Start semua VM
./start.sh

# Stop semua
./stop.sh

# Restart
./restart.sh

# Status
./status.sh

# Menu interaktif
lua cloud-vmos-controller.lua
```

---

## Estimasi Resource

| RAM Cloud Phone | Jumlah VM | RAM per VM |
|-----------------|-----------|------------|
| 4GB | 1-2 | 2GB |
| 6GB | 2-3 | 2GB |
| 8GB | 3-5 | 2GB |
| 12GB | 5-8 | 2GB |

---

Terakhir diperbarui: 1 Juli 2026
