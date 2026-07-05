-- ============================================
-- GAG2 Auto-Start System
-- ============================================
-- Otomatis buka Roblox dan jalankan bot
-- Setelah cloud phone restart

-- ============================================
-- CONFIG
-- ============================================

local Config = {
    -- Game
    place_id = 97598239454123,
    
    -- Delay (detik)
    boot_delay = 30,           -- Tunggu setelah boot
    app_launch_delay = 10,     -- Delay setelah buka app
    game_load_delay = 20,      -- Delay setelah join game
    script_load_delay = 10,    -- Delay sebelum load script
    
    -- Auto-restart
    check_interval = 300,      -- Cek setiap 5 menit
    restart_on_crash = true,   -- Restart jika crash
    
    -- Script URL
    script_url = "https://raw.githubusercontent.com/fannyf123/GAG2-Farm/master/gag2-all-in-one.lua",
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

-- ============================================
-- ROBLOX CONTROL
-- ============================================

local function IsRobloxRunning()
    local handle = io.popen("pidof com.roblox.client 2>/dev/null")
    local result = handle:read("*a")
    handle:close()
    return result ~= ""
end

local function OpenRoblox()
    Log("Membuka Roblox...")
    os.execute("am start -n com.roblox.client/.ActivityProtocol")
    Sleep(Config.app_launch_delay)
end

local function JoinGame()
    Log("Join game GAG2...")
    local url = "roblox://placeId=" .. Config.place_id
    os.execute("am start -a android.intent.action.VIEW -d '" .. url .. "'")
    Sleep(Config.game_load_delay)
end

local function CloseRoblox()
    Log("Menutup Roblox...")
    os.execute("am force-stop com.roblox.client")
    Sleep(2)
end

local function RestartRoblox()
    Log("Restart Roblox...")
    CloseRoblox()
    Sleep(5)
    OpenRoblox()
    JoinGame()
end

-- ============================================
-- SCRIPT INJECTION
-- ============================================

local function InjectScript()
    Log("Injecting farming script...")
    
    -- Method 1: Load via executor auto-execute
    -- Script sudah ada di folder auto-execute
    
    -- Method 2: Inject via clipboard (jika executor support)
    local script_content = [[
        loadstring(game:HttpGet("]] .. Config.script_url .. [["))()
    ]]
    
    -- Copy to clipboard jika bisa
    pcall(function()
        os.execute("termux-clipboard-set '" .. script_content .. "'")
        Log("Script copied to clipboard")
    end)
    
    Log("Script ready! Paste di executor jika diperlukan")
end

-- ============================================
-- DELTA EXECUTOR AUTO-START
-- ============================================

local function SetupDeltaAutoStart()
    Log("Setting up Delta auto-start...")
    
    -- Buat file auto-execute
    local autoexec_path = "/storage/emulated/0/Delta/Autoexecute/gag2farm.lua"
    local script_content = [[
-- GAG2 Auto Farm - Auto-Execute
if game.PlaceId ~= 97598239454123 then
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
loadstring(game:HttpGet("https://raw.githubusercontent.com/fannyf123/GAG2-Farm/master/gag2-all-in-one.lua"))()
]]
    
    -- Tulis file
    local file = io.open(autoexec_path, "w")
    if file then
        file:write(script_content)
        file:close()
        Log("Delta auto-execute script saved: " .. autoexec_path)
    else
        Log("Gagal menyimpan script Delta")
    end
end

-- ============================================
-- BOOT SEQUENCE
-- ============================================

local function BootSequence()
    Log("========================================")
    Log("  GAG2 Auto-Start System")
    Log("========================================")
    Log("")
    
    -- Tunggu setelah boot
    Log("Menunggu " .. Config.boot_delay .. " detik setelah boot...")
    Sleep(Config.boot_delay)
    
    -- Setup Delta auto-start
    SetupDeltaAutoStart()
    
    -- Buka Roblox
    OpenRoblox()
    
    -- Join game
    JoinGame()
    
    -- Tunggu game load
    Log("Menunggu game load...")
    Sleep(Config.game_load_delay)
    
    -- Inject script
    InjectScript()
    
    Log("")
    Log("========================================")
    Log("  Auto-start selesai!")
    Log("  Roblox sudah dibuka dan join game")
    Log("  Script akan otomatis jalan via Delta")
    Log("========================================")
end

-- ============================================
-- MONITOR & AUTO-RESTART
-- ============================================

local function MonitorLoop()
    Log("Monitor loop dimulai...")
    Log("Cek setiap " .. Config.check_interval .. " detik")
    
    while true do
        Sleep(Config.check_interval)
        
        if Config.restart_on_crash then
            if not IsRobloxRunning() then
                Log("Roblox tidak berjalan! Restarting...")
                RestartRoblox()
                Sleep(Config.game_load_delay)
                InjectScript()
            else
                Log("Roblox berjalan normal")
            end
        end
    end
end

-- ============================================
-- MAIN
-- ============================================

local function Main()
    -- Cek apakah ada argumen
    local args = {...}
    local mode = args[1] or "boot"
    
    if mode == "boot" then
        -- Boot sequence (dijalankan saat startup)
        BootSequence()
        
        -- Mulai monitor
        MonitorLoop()
        
    elseif mode == "monitor" then
        -- Hanya monitor
        MonitorLoop()
        
    elseif mode == "start" then
        -- Manual start
        OpenRoblox()
        JoinGame()
        InjectScript()
        
    elseif mode == "stop" then
        -- Stop
        CloseRoblox()
        
    elseif mode == "restart" then
        -- Restart
        RestartRoblox()
        InjectScript()
        
    elseif mode == "setup" then
        -- Setup saja
        SetupDeltaAutoStart()
        
    else
        print("GAG2 Auto-Start System")
        print("")
        print("Usage:")
        print("  lua auto-start.lua boot     - Boot sequence + monitor")
        print("  lua auto-start.lua monitor  - Monitor only")
        print("  lua auto-start.lua start    - Manual start")
        print("  lua auto-start.lua stop     - Stop Roblox")
        print("  lua auto-start.lua restart  - Restart Roblox")
        print("  lua auto-start.lua setup    - Setup Delta auto-execute")
    end
end

-- Jalankan
Main()
