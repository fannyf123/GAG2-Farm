# VMOS + Termux Multi-Bot Setup

> Tutorial lengkap menjalankan 5-10 bot GAG2 dengan VMOS + Termux

---

## Kelebihan Metode Ini

| Kelebihan | Keterangan |
|-----------|------------|
| ✅ **Hemat modal** | Tidak perlu beli cloud phone |
| ✅ **Banyak bot** | Bisa 5-10 bot dalam 1 HP |
| ✅ **Full kontrol** | Semua dijalankan dari HP sendiri |
| ✅ **Otomatis** | Termux mengontrol semua bot |
| ✅ **Gratis** | Tidak ada biaya bulanan |

---

## Kebutuhan

| Komponen | Minimum | Rekomendasi |
|----------|---------|-------------|
| **HP Android** | RAM 6GB | RAM 8-12GB |
| **Storage** | 32GB | 64-128GB |
| **Internet** | 5 Mbps | 10+ Mbps |
| **Android** | 8.0+ | 10+ |

---

## Struktur Sistem

```
HP Anda
├── Termux (Controller/Brain)
│   ├── Multi-bot controller script
│   ├── Auto-rejoin system
│   ├── Monitor & notification
│   └── Discord webhook
│
├── VMOS VM 1 (Bot 1)
│   ├── Roblox
│   ├── Delta Executor
│   └── GAG2 Farm Script
│
├── VMOS VM 2 (Bot 2)
│   ├── Roblox
│   ├── Delta Executor
│   └── GAG2 Farm Script
│
├── VMOS VM 3 (Bot 3)
│   ├── Roblox
│   ├── Delta Executor
│   └── GAG2 Farm Script
│
└── ... (tergantung RAM)
```

---

## Langkah 1: Install Aplikasi

### 1.1 Install VMOS Pro

1. Buka browser di HP
2. Kunjungi: https://www.vmos.com/
3. Download **VMOS Pro**
4. Install APK
5. Buka VMOS Pro
6. Tunggu loading pertama

### 1.2 Install Termux

1. Kunjungi: https://f-droid.org/repo/com.termux_1002.apk
2. Download dan install
3. Buka Termux
4. Jalankan:

```bash
termux-setup-storage
pkg update && pkg upgrade
pkg install lua53 python git wget curl
```

### 1.3 Install Termux:API (Opsional)

```bash
pkg install termux-api
```

Download Termux:API app: https://f-droid.org/repo/com.termux.api_1002.apk

---

## Langkah 2: Buat VM di VMOS

### 2.1 Buat VM Pertama

1. Buka VMOS Pro
2. Klik **"Add VM"** atau **"+"**
3. Pilih:
   - **Android Version:** 10
   - **RAM:** 2GB (sesuaikan dengan HP)
   - **Storage:** 8GB
4. Tunggu proses selesai (5-10 menit)

### 2.2 Setup VM Pertama

1. Buka VM yang sudah dibuat
2. Buka **Play Store**
3. Login dengan akun Google (buat baru jika perlu)
4. Install **Roblox**
5. Install **Delta Executor** (download dari https://delta-executor.com/)

### 2.3 Setup Delta di VM

1. Buka Delta Executor
2. Get Key (pakai Zen Bypass: https://izen.lol/)
3. Paste key
4. Delta aktif

### 2.4 Setup Script Auto-Execute

1. Buka File Manager di VM
2. Buka folder `/storage/emulated/0/Delta/Autoexecute/`
3. Buat file `gag2farm.lua`
4. Isi dengan:

```lua
-- GAG2 Auto Farm
if game.PlaceId ~= 5765122481 then
    return
end

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

5. Save file

### 2.5 Login Akun Roblox

1. Buka Roblox di VM
2. Login dengan akun bot
3. Tutup Roblox

### 2.6 Clone VM untuk Bot Lain

1. Kembali ke VMOS Pro (luar VM)
2. Klik icon titik tiga di VM 1
3. Pilih **"Clone"** atau **"Duplicate"**
4. Beri nama "Bot 2"
5. Ulangi untuk Bot 3, 4, 5, dst

**Tips:** Clone VM membuat salinan persis, termasuk Delta dan script.

### 2.7 Login Akun Berbeda di Setiap VM

1. Buka VM 2 (Bot 2)
2. Buka Roblox
3. Logout dari akun sebelumnya
4. Login dengan akun bot 2
5. Ulangi untuk setiap VM

---

## Langkah 3: Setup Termux Controller

### 3.1 Download Script Controller

Di Termux:

```bash
cd /sdcard/Download
mkdir -p gag2-controller
cd gag2-controller
```

### 3.2 Buat Script Controller

```bash
nano controller.lua
```

Paste kode berikut:

```lua
-- ============================================
-- GAG2 Multi-Bot Controller
-- Untuk Termux + VMOS
-- ============================================

local json = require("dkjson")

-- ============================================
-- CONFIG
-- ============================================

local Config = {
    -- Jumlah bot
    num_bots = 3,  -- Sesuaikan dengan jumlah VM
    
    -- Delay (detik)
    start_delay = 10,      -- Delay antar start bot
    monitor_interval = 60,  -- Interval cek status
    reconnect_delay = 30,   -- Delay sebelum reconnect
    
    -- Discord Webhook (opsional)
    webhook_url = "",  -- Isi dengan webhook URL jika ingin notifikasi
    
    -- Game
    place_id = 5765122481,  -- GAG2 Place ID
}

-- ============================================
-- STATE
-- ============================================

local State = {
    bots = {},
    start_time = os.time(),
    total_reconnects = 0,
}

-- ============================================
-- UTILITY
-- ============================================

local function Log(message)
    local timestamp = os.date("%H:%M:%S")
    print(string.format("[%s] %s", timestamp, message))
end

local function SendWebhook(message)
    if Config.webhook_url == "" then return end
    
    local http = require("socket.http")
    local ltn12 = require("ltn12")
    
    local payload = json.encode({
        content = message
    })
    
    http.request{
        url = Config.webhook_url,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#payload)
        },
        source = ltn12.source.string(payload),
    }
end

-- ============================================
-- VMOS CONTROL
-- ============================================

local function OpenVMOS()
    Log("Membuka VMOS...")
    os.execute("am start -n com.vmos.pro/.MainActivity")
    os.sleep(5)
end

local function OpenVM(vm_index)
    Log("Membuka VM " .. vm_index .. "...")
    -- Tap pada VM ke-n di VMOS
    -- Posisi tergantung layout VMOS
    local y = 200 + (vm_index * 120)
    os.execute("input tap 540 " .. y)
    os.sleep(8)
end

local function OpenRoblox()
    Log("Membuka Roblox...")
    os.execute("am start -n com.roblox.client/com.roblox.client.ActivityProtocol")
    os.sleep(10)
end

local function JoinGame(place_id)
    Log("Join game " .. place_id .. "...")
    local url = "roblox://placeId=" .. place_id
    os.execute("am start -a android.intent.action.VIEW -d '" .. url .. "'")
    os.sleep(15)
end

local function CloseRoblox()
    Log("Menutup Roblox...")
    os.execute("am force-stop com.roblox.client")
    os.sleep(2)
end

local function CloseVMOS()
    Log("Menutup VMOS...")
    os.execute("am force-stop com.vmos.pro")
    os.sleep(2)
end

-- ============================================
-- BOT MANAGEMENT
-- ============================================

local function StartBot(bot_index)
    Log("Memulai Bot " .. bot_index .. "...")
    
    -- Buka VMOS
    OpenVMOS()
    
    -- Buka VM
    OpenVM(bot_index)
    
    -- Buka Roblox
    OpenRoblox()
    
    -- Join game
    JoinGame(Config.place_id)
    
    -- Update state
    State.bots[bot_index] = {
        status = "running",
        start_time = os.time(),
        last_check = os.time(),
    }
    
    Log("Bot " .. bot_index .. " berhasil dimulai!")
    SendWebhook("[Bot " .. bot_index .. "] Started")
    
    -- Kembali ke Termux
    os.execute("input keyevent KEYCODE_HOME")
    os.sleep(2)
end

local function StopBot(bot_index)
    Log("Menghentikan Bot " .. bot_index .. "...")
    
    -- Buka VMOS
    OpenVMOS()
    
    -- Buka VM
    OpenVM(bot_index)
    
    -- Tutup Roblox
    CloseRoblox()
    
    -- Update state
    if State.bots[bot_index] then
        State.bots[bot_index].status = "stopped"
    end
    
    Log("Bot " .. bot_index .. " dihentikan")
    SendWebhook("[Bot " .. bot_index .. "] Stopped")
    
    -- Kembali ke Termux
    os.execute("input keyevent KEYCODE_HOME")
    os.sleep(2)
end

local function RestartBot(bot_index)
    Log("Restart Bot " .. bot_index .. "...")
    StopBot(bot_index)
    os.sleep(5)
    StartBot(bot_index)
    State.total_reconnects = State.total_reconnects + 1
end

-- ============================================
-- MONITORING
-- ============================================

local function CheckBotStatus(bot_index)
    -- Ini adalah simplified check
    -- Di implementasi nyata, Anda perlu cek apakah Roblox masih jalan
    
    local bot = State.bots[bot_index]
    if not bot then return "unknown" end
    
    local time_since_start = os.time() - bot.start_time
    
    -- Jika sudah jalan lebih dari 2 jam, mungkin perlu restart
    if time_since_start > 7200 then
        return "needs_restart"
    end
    
    return "running"
end

local function MonitorBots()
    Log("Monitoring semua bot...")
    
    for i = 1, Config.num_bots do
        local status = CheckBotStatus(i)
        
        if status == "needs_restart" then
            Log("Bot " .. i .. " perlu restart")
            RestartBot(i)
        elseif status == "running" then
            Log("Bot " .. i .. " berjalan normal")
        end
    end
end

-- ============================================
-- STATS
-- ============================================

local function ShowStats()
    local uptime = os.time() - State.start_time
    local hours = math.floor(uptime / 3600)
    local minutes = math.floor((uptime % 3600) / 60)
    
    print("\n========================================")
    print("  GAG2 Multi-Bot Controller Stats")
    print("========================================")
    print("  Uptime: " .. hours .. "h " .. minutes .. "m")
    print("  Total Bots: " .. Config.num_bots)
    print("  Total Reconnects: " .. State.total_reconnects)
    print("")
    
    for i = 1, Config.num_bots do
        local bot = State.bots[i]
        if bot then
            local bot_uptime = os.time() - bot.start_time
            local bot_hours = math.floor(bot_uptime / 3600)
            local bot_minutes = math.floor((bot_uptime % 3600) / 60)
            print(string.format("  Bot %d: %s (%dh %dm)", i, bot.status, bot_hours, bot_minutes))
        else
            print(string.format("  Bot %d: not started", i))
        end
    end
    
    print("========================================\n")
end

-- ============================================
-- MAIN
-- ============================================

local function Main()
    print([[
╔═══════════════════════════════════════════════════════════════╗
║           GAG2 Multi-Bot Controller v1.0.0                    ║
║           Untuk Termux + VMOS Pro                             ║
╚═══════════════════════════════════════════════════════════════╝
]])
    
    Log("Memulai controller...")
    Log("Jumlah bot: " .. Config.num_bots)
    Log("")
    
    -- Mulai semua bot
    for i = 1, Config.num_bots do
        StartBot(i)
        os.sleep(Config.start_delay)
    end
    
    Log("")
    Log("Semua bot sudah dimulai!")
    Log("Monitor interval: " .. Config.monitor_interval .. " detik")
    Log("Tekan Ctrl+C untuk berhenti")
    Log("")
    
    -- Monitor loop
    while true do
        os.sleep(Config.monitor_interval)
        MonitorBots()
        ShowStats()
    end
end

-- Jalankan
Main()
```

Save file (Ctrl+X, Y, Enter).

### 3.3 Buat Script Auto-Rejoin

```bash
nano auto-rejoin.lua
```

Paste kode berikut:

```lua
-- ============================================
-- GAG2 Auto-Rejoin Script
-- Untuk Termux
-- ============================================

local Config = {
    place_id = 5765122481,
    check_interval = 300,  -- Cek setiap 5 menit
    reconnect_delay = 30,
}

local function Log(message)
    local timestamp = os.date("%H:%M:%S")
    print(string.format("[%s] %s", timestamp, message))
end

local function IsRobloxRunning()
    local handle = io.popen("pidof com.roblox.client")
    local result = handle:read("*a")
    handle:close()
    return result ~= ""
end

local function RejoinGame()
    Log("Rejoining game...")
    
    -- Tutup Roblox
    os.execute("am force-stop com.roblox.client")
    os.sleep(5)
    
    -- Buka Roblox dan join game
    local url = "roblox://placeId=" .. Config.place_id
    os.execute("am start -a android.intent.action.VIEW -d '" .. url .. "'")
    
    Log("Rejoin berhasil!")
end

local function Main()
    Log("Auto-Rejoin dimulai")
    Log("Cek interval: " .. Config.check_interval .. " detik")
    
    while true do
        os.sleep(Config.check_interval)
        
        if not IsRobloxRunning() then
            Log("Roblox tidak berjalan, rejoining...")
            os.sleep(Config.reconnect_delay)
            RejoinGame()
        else
            Log("Roblox berjalan normal")
        end
    end
end

Main()
```

Save file.

### 3.4 Buat Script Start/Stop

```bash
nano start-all.sh
```

Paste:

```bash
#!/bin/bash
# Start semua bot

echo "=== Memulai semua bot GAG2 ==="

# Jalankan controller
lua controller.lua &
CONTROLLER_PID=$!

echo "Controller PID: $CONTROLLER_PID"
echo "Semua bot sudah dimulai!"
echo "Tekan Ctrl+C untuk berhenti"

# Tunggu
wait $CONTROLLER_PID
```

```bash
nano stop-all.sh
```

Paste:

```bash
#!/bin/bash
# Stop semua bot

echo "=== Menghentikan semua bot GAG2 ==="

# Tutup Roblox
am force-stop com.roblox.client

# Tutup VMOS
am force-stop com.vmos.pro

echo "Semua bot dihentikan!"
```

```bash
chmod +x start-all.sh stop-all.sh
```

---

## Langkah 4: Jalankan

### 4.1 Start Semua Bot

```bash
cd /sdcard/Download/gag2-controller
./start-all.sh
```

### 4.2 Monitor

Controller akan menampilkan:

```
[12:00:00] Memulai Bot 1...
[12:00:05] Membuka VMOS...
[12:00:10] Membuka VM 1...
[12:00:18] Membuka Roblox...
[12:00:28] Join game 5765122481...
[12:00:43] Bot 1 berhasil dimulai!
[12:00:48] Memulai Bot 2...
...
```

### 4.3 Stop Semua Bot

```bash
./stop-all.sh
```

---

## Langkah 5: Discord Webhook (Opsional)

### 5.1 Buat Webhook

1. Buka Discord
2. Buka Server Settings → Integrations → Webhooks
3. Klik "New Webhook"
4. Copy webhook URL

### 5.2 Edit Config

Edit `controller.lua`:

```lua
local Config = {
    ...
    webhook_url = "https://discord.com/api/webhooks/...",
    ...
}
```

### 5.3 Notifikasi yang Dikirim

```
[Bot 1] Started
[Bot 2] Started
[Bot 1] Needs restart
[Bot 1] Restarted
```

---

## Tips & Trik

### Hemat Resource

| Tips | Efek |
|------|------|
| **FPS Cap 10** | Hemat CPU 60% |
| **Disable rendering** | Hemat GPU 80% |
| **Remove visuals** | Hemat RAM 30% |
| **1-2GB RAM per VM** | Cukup untuk farming |

### Jaga Stabilitas

| Tips | Keterangan |
|------|------------|
| **Restart 1x/hari** | Bersihkan memory leak |
| **Monitor HP** | Jangan sampai overheating |
| **Charger** | Selalu charger saat running |
| **Jangan terlalu banyak VM** | Sesuaikan dengan RAM |

### Estimasi Resource

| RAM HP | Jumlah VM | Keterangan |
|--------|-----------|------------|
| 6GB | 2-3 VM | Cukup untuk 2-3 bot |
| 8GB | 3-5 VM | Ideal untuk 3-5 bot |
| 12GB | 5-8 VM | Bisa 5-8 bot |
| 16GB | 8-10 VM | Maksimal 8-10 bot |

---

## Troubleshooting

| Masalah | Solusi |
|---------|--------|
| **VMOS crash** | Kurangi jumlah VM |
| **HP panas** | Kurangi FPS cap, istirahatkan HP |
| **Bot berhenti** | Auto-rejoin akan restart otomatis |
| **Script error** | Update script dari GitHub |
| **Delta expired** | Get key baru untuk setiap VM |

---

## Estimasi Biaya

| Komponen | Biaya |
|----------|-------|
| **VMOS Pro** | Gratis (ada iklan) atau $5/bulan (Pro) |
| **Termux** | Gratis |
| **Script** | Gratis |
| **Delta Key** | Gratis (dengan Zen Bypass) |
| **Total** | **$0 - $5/bulan** |

---

## Ringkasan

| Komponen | Fungsi |
|----------|--------|
| **VMOS Pro** | Menjalankan banyak Roblox |
| **Termux** | Mengontrol semua bot |
| **Controller Script** | Otomasi start/stop/monitor |
| **Auto-Rejoin** | Rejoin jika disconnect |
| **Discord Webhook** | Notifikasi |

---

Terakhir diperbarui: 1 Juli 2026
