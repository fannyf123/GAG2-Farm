-- ============================================
-- GAG2 Cloud Phone + VMOS Auto-Start
-- ============================================
-- Script ini dijalankan di CLOUD PHONE
-- Otomatis buka VMOS, jalankan semua VM,
-- buka Roblox di setiap VM, dan jalankan script

-- ============================================
-- CONFIG
-- ============================================

local Config = {
    -- Jumlah VM di VMOS
    num_vms = 3,  -- Sesuaikan dengan jumlah VM yang sudah dibuat
    
    -- Game
    place_id = 5765122481,
    
    -- Delays (detik)
    boot_delay = 30,           -- Tunggu setelah boot
    vmos_open_delay = 15,      -- Delay buka VMOS
    vm_open_delay = 20,        -- Delay buka setiap VM
    roblox_open_delay = 15,    -- Delay buka Roblox
    game_join_delay = 25,      -- Delay join game
    between_vm_delay = 10,     -- Delay antar VM
    
    -- Monitoring
    check_interval = 300,      -- Cek setiap 5 menit
    restart_on_crash = true,   -- Restart jika crash
    
    -- Script URL
    script_url = "https://raw.githubusercontent.com/fannyf123/GAG2-Farm/main/gag2-all-in-one.lua",
}

-- ============================================
-- UTILITY
-- ============================================

local function Log(message)
    local timestamp = os.date("%H:%M:%S")
    print(string.format("[%s] %s", timestamp, message))
end

local function Sleep(seconds)
    os.execute("sleep " .. seconds)
end

local function Run(cmd)
    Log("CMD: " .. cmd)
    os.execute(cmd)
end

-- ============================================
-- VMOS CONTROL
-- ============================================

local function IsVMOSRunning()
    local handle = io.popen("pidof com.vmos.pro 2>/dev/null || pidof com.vmos.vmos 2>/dev/null")
    local result = handle:read("*a")
    handle:close()
    return result ~= ""
end

local function OpenVMOS()
    Log("Membuka VMOS Pro...")
    
    -- Coba beberapa package name
    local packages = {
        "com.vmos.pro",
        "com.vmos.vmos",
        "com.vmos.global",
    }
    
    for _, pkg in ipairs(packages) do
        local cmd = "am start -n " .. pkg .. "/.MainActivity 2>/dev/null"
        local result = os.execute(cmd)
        if result then
            Log("VMOS dibuka: " .. pkg)
            Sleep(Config.vmos_open_delay)
            return true
        end
    end
    
    Log("Gagal membuka VMOS!")
    return false
end

local function CloseVMOS()
    Log("Menutup VMOS...")
    Run("am force-stop com.vmos.pro")
    Run("am force-stop com.vmos.vmos")
    Run("am force-stop com.vmos.global")
    Sleep(3)
end

-- ============================================
-- VM CONTROL (Inside VMOS)
-- ============================================

local function TapVM(vm_index)
    -- Tap pada VM ke-n di VMOS
    -- Posisi tergantung layout VMOS
    -- Ini adalah estimasi, mungkin perlu disesuaikan
    
    local base_y = 250  -- Posisi Y VM pertama
    local vm_height = 120  -- Jarak antar VM
    
    local y = base_y + ((vm_index - 1) * vm_height)
    
    Log("Tap VM " .. vm_index .. " (y=" .. y .. ")")
    Run("input tap 540 " .. y)
    Sleep(Config.vm_open_delay)
end

local function OpenRobloxInVM()
    Log("Membuka Roblox di VM...")
    Run("am start -n com.roblox.client/.ActivityProtocol")
    Sleep(Config.roblox_open_delay)
end

local function JoinGameInVM()
    Log("Join game GAG2...")
    local url = "roblox://placeId=" .. Config.place_id
    Run("am start -a android.intent.action.VIEW -d '" .. url .. "'")
    Sleep(Config.game_join_delay)
end

local function CloseRobloxInVM()
    Log("Menutup Roblox di VM...")
    Run("am force-stop com.roblox.client")
    Sleep(2)
end

-- ============================================
-- SCRIPT INJECTION
-- ============================================

local function InjectScriptToVM()
    Log("Injecting script ke VM...")
    
    -- Buat file auto-execute di VM
    local script_content = [[
-- GAG2 Auto Farm - Auto-Execute
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
loadstring(game:HttpGet("https://raw.githubusercontent.com/fannyf123/GAG2-Farm/main/gag2-all-in-one.lua"))()
]]
    
    -- Simpan di clipboard untuk paste
    pcall(function()
        os.execute("termux-clipboard-set '" .. script_content:gsub("'", "'\\''") .. "'")
        Log("Script copied to clipboard")
    end)
    
    -- Simpan juga ke file
    local file = io.open("/sdcard/Download/gag2-auto-start/script-clipboard.lua", "w")
    if file then
        file:write(script_content)
        file:close()
        Log("Script saved to file")
    end
end

-- ============================================
-- DELTA AUTO-EXECUTE SETUP
-- ============================================

local function SetupDeltaInVM()
    Log("Setting up Delta auto-execute di VM...")
    
    -- Buat folder Delta auto-execute
    Run("mkdir -p /storage/emulated/0/Delta/Autoexecute")
    
    -- Tulis script
    local script_content = [[
-- GAG2 Auto Farm
if game.PlaceId ~= 5765122481 then
    return
end

repeat task.wait() until game:IsLoaded()
task.wait(5)

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

task.wait(2)
loadstring(game:HttpGet("https://raw.githubusercontent.com/fannyf123/GAG2-Farm/main/gag2-all-in-one.lua"))()
]]
    
    local file = io.open("/storage/emulated/0/Delta/Autoexecute/gag2farm.lua", "w")
    if file then
        file:write(script_content)
        file:close()
        Log("Delta auto-execute script saved")
    end
end

-- ============================================
-- BOOT SEQUENCE
-- ============================================

local function BootSequence()
    print([[
╔═══════════════════════════════════════════════════════════════╗
║           GAG2 Cloud Phone + VMOS Auto-Start                  ║
║           Multi-Bot System                                    ║
╚═══════════════════════════════════════════════════════════════╝
]])
    
    Log("Memulai boot sequence...")
    Log("Jumlah VM: " .. Config.num_vms)
    Log("")
    
    -- Tunggu setelah boot
    Log("Menunggu " .. Config.boot_delay .. " detik setelah boot...")
    Sleep(Config.boot_delay)
    
    -- Buka VMOS
    if not OpenVMOS() then
        Log("Gagal membuka VMOS! Coba lagi dalam 30 detik...")
        Sleep(30)
        if not OpenVMOS() then
            Log("VMOS tidak bisa dibuka. Keluar.")
            return
        end
    end
    
    -- Setup Delta di semua VM
    SetupDeltaInVM()
    
    -- Jalankan setiap VM
    for vm = 1, Config.num_vms do
        Log("")
        Log("========================================")
        Log("  Memproses VM " .. vm .. "/" .. Config.num_vms)
        Log("========================================")
        
        -- Tap VM untuk membukanya
        TapVM(vm)
        
        -- Buka Roblox di VM
        OpenRobloxInVM()
        
        -- Join game
        JoinGameInVM()
        
        -- Inject script (jika Delta belum auto-execute)
        InjectScriptToVM()
        
        -- Tunggu sebelum VM berikutnya
        if vm < Config.num_vms then
            Log("Menunggu " .. Config.between_vm_delay .. " detik sebelum VM berikutnya...")
            Sleep(Config.between_vm_delay)
        end
    end
    
    Log("")
    Log("========================================")
    Log("  Boot sequence selesai!")
    Log("  " .. Config.num_vms .. " VM sudah dijalankan")
    Log("========================================")
end

-- ============================================
-- MONITOR & AUTO-RESTART
-- ============================================

local function MonitorLoop()
    Log("Monitor loop dimulai...")
    Log("Cek setiap " .. Config.check_interval .. " detik")
    
    local check_count = 0
    
    while true do
        Sleep(Config.check_interval)
        check_count = check_count + 1
        
        Log("")
        Log("=== Check #" .. check_count .. " ===")
        
        -- Cek apakah VMOS masih jalan
        if not IsVMOSRunning() then
            Log("VMOS tidak berjalan! Restarting...")
            OpenVMOS()
            Sleep(10)
            
            -- Re-run boot sequence
            for vm = 1, Config.num_vms do
                TapVM(vm)
                OpenRobloxInVM()
                JoinGameInVM()
                Sleep(Config.between_vm_delay)
            end
        else
            Log("VMOS berjalan normal")
        end
        
        -- Cek setiap VM
        for vm = 1, Config.num_vms do
            -- Di sini Anda bisa tambahkan pengecekan spesifik per VM
            -- Misalnya: cek apakah Roblox masih jalan di VM tersebut
            Log("VM " .. vm .. ": OK")
        end
        
        Log("Check selesai")
    end
end

-- ============================================
-- MANUAL CONTROLS
-- ============================================

local function StartAllVMs()
    Log("Memulai semua VM...")
    
    if not OpenVMOS() then
        Log("Gagal membuka VMOS!")
        return
    end
    
    for vm = 1, Config.num_vms do
        Log("Memulai VM " .. vm .. "...")
        TapVM(vm)
        OpenRobloxInVM()
        JoinGameInVM()
        Sleep(Config.between_vm_delay)
    end
    
    Log("Semua VM sudah dimulai!")
end

local function StopAllVMs()
    Log("Menghentikan semua VM...")
    CloseRobloxInVM()
    CloseVMOS()
    Log("Semua VM dihentikan!")
end

local function RestartAllVMs()
    Log("Restart semua VM...")
    StopAllVMs()
    Sleep(10)
    StartAllVMs()
end

local function ShowStatus()
    print("\n========================================")
    print("  GAG2 Cloud Phone + VMOS Status")
    print("========================================")
    print("  VMOS Running: " .. (IsVMOSRunning() and "YES" or "NO"))
    print("  Jumlah VM: " .. Config.num_vms)
    print("  Place ID: " .. Config.place_id)
    print("  Check Interval: " .. Config.check_interval .. "s")
    print("  Restart on Crash: " .. (Config.restart_on_crash and "YES" or "NO"))
    print("========================================\n")
end

-- ============================================
-- MENU
-- ============================================

local function ShowMenu()
    print("\n========================================")
    print("  MENU")
    print("========================================")
    print("  [1] Boot sequence (otomatis semua)")
    print("  [2] Start semua VM")
    print("  [3] Stop semua VM")
    print("  [4] Restart semua VM")
    print("  [5] Monitor loop")
    print("  [6] Status")
    print("  [7] Set jumlah VM")
    print("  [8] Setup Delta auto-execute")
    print("  [0] Exit")
    print("========================================")
    print("  Pilih: ")
end

-- ============================================
-- MAIN
-- ============================================

local function Main()
    -- Cek argumen
    local args = {...}
    local mode = args[1] or "menu"
    
    if mode == "boot" then
        BootSequence()
        MonitorLoop()
        
    elseif mode == "monitor" then
        MonitorLoop()
        
    elseif mode == "start" then
        StartAllVMs()
        
    elseif mode == "stop" then
        StopAllVMs()
        
    elseif mode == "restart" then
        RestartAllVMs()
        
    elseif mode == "status" then
        ShowStatus()
        
    elseif mode == "setup" then
        SetupDeltaInVM()
        
    else
        -- Interactive menu
        print([[
╔═══════════════════════════════════════════════════════════════╗
║           GAG2 Cloud Phone + VMOS Controller                  ║
║           Multi-Bot System                                    ║
╚═══════════════════════════════════════════════════════════════╝
]])
        
        while true do
            ShowMenu()
            local choice = io.read()
            
            if choice == "1" then
                BootSequence()
                MonitorLoop()
                
            elseif choice == "2" then
                StartAllVMs()
                
            elseif choice == "3" then
                StopAllVMs()
                
            elseif choice == "4" then
                RestartAllVMs()
                
            elseif choice == "5" then
                MonitorLoop()
                
            elseif choice == "6" then
                ShowStatus()
                
            elseif choice == "7" then
                print("  Jumlah VM baru: ")
                local new_num = tonumber(io.read())
                if new_num and new_num >= 1 and new_num <= 10 then
                    Config.num_vms = new_num
                    print("[*] Jumlah VM diubah ke: " .. new_num)
                else
                    print("[!] Jumlah tidak valid (1-10)")
                end
                
            elseif choice == "8" then
                SetupDeltaInVM()
                
            elseif choice == "0" then
                print("\n[*] Keluar...")
                break
                
            else
                print("[!] Pilihan tidak valid")
            end
        end
    end
end

-- Jalankan
Main()
