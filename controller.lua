-- ============================================
-- GAG2 Multi-Bot Controller
-- Untuk Termux + VMOS Pro
-- ============================================

-- Load JSON library
local function LoadJSON()
    local success, json = pcall(require, "dkjson")
    if success then return json end
    
    -- Fallback simple JSON parser
    return {
        encode = function(obj)
            if type(obj) == "table" then
                local parts = {}
                for k, v in pairs(obj) do
                    table.insert(parts, '"' .. k .. '":"' .. tostring(v) .. '"')
                end
                return "{" .. table.concat(parts, ",") .. "}"
            end
            return tostring(obj)
        end,
        decode = function(str)
            -- Simple fallback
            return {}
        end
    }
end

local json = LoadJSON()

-- ============================================
-- CONFIG
-- ============================================

local Config = {
    num_bots = 3,
    start_delay = 10,
    monitor_interval = 60,
    reconnect_delay = 30,
    webhook_url = "",
    place_id = 97598239454123,
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
        content = "[GAG2 Controller] " .. message
    })
    
    pcall(function()
        http.request{
            url = Config.webhook_url,
            method = "POST",
            headers = {
                ["Content-Type"] = "application/json",
                ["Content-Length"] = tostring(#payload)
            },
            source = ltn12.source.string(payload),
        }
    end)
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

-- ============================================
-- BOT MANAGEMENT
-- ============================================

local function StartBot(bot_index)
    Log("Memulai Bot " .. bot_index .. "...")
    
    OpenVMOS()
    OpenVM(bot_index)
    OpenRoblox()
    JoinGame(Config.place_id)
    
    State.bots[bot_index] = {
        status = "running",
        start_time = os.time(),
        last_check = os.time(),
    }
    
    Log("Bot " .. bot_index .. " berhasil dimulai!")
    SendWebhook("Bot " .. bot_index .. " started")
    
    os.execute("input keyevent KEYCODE_HOME")
    os.sleep(2)
end

local function StopBot(bot_index)
    Log("Menghentikan Bot " .. bot_index .. "...")
    
    OpenVMOS()
    OpenVM(bot_index)
    CloseRoblox()
    
    if State.bots[bot_index] then
        State.bots[bot_index].status = "stopped"
    end
    
    Log("Bot " .. bot_index .. " dihentikan")
    SendWebhook("Bot " .. bot_index .. " stopped")
    
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
    local bot = State.bots[bot_index]
    if not bot then return "unknown" end
    
    local time_since_start = os.time() - bot.start_time
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
-- MENU
-- ============================================

local function ShowMenu()
    print("\n========================================")
    print("  MENU")
    print("========================================")
    print("  [1] Start semua bot")
    print("  [2] Stop semua bot")
    print("  [3] Restart semua bot")
    print("  [4] Start bot tertentu")
    print("  [5] Stop bot tertentu")
    print("  [6] Show stats")
    print("  [7] Monitor loop")
    print("  [0] Exit")
    print("========================================")
    print("  Pilih: ")
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
    
    while true do
        ShowMenu()
        local choice = io.read()
        
        if choice == "1" then
            for i = 1, Config.num_bots do
                StartBot(i)
                os.sleep(Config.start_delay)
            end
            print("\n[*] Semua bot sudah dimulai!")
            
        elseif choice == "2" then
            for i = 1, Config.num_bots do
                StopBot(i)
                os.sleep(3)
            end
            print("\n[*] Semua bot dihentikan!")
            
        elseif choice == "3" then
            for i = 1, Config.num_bots do
                RestartBot(i)
                os.sleep(Config.start_delay)
            end
            print("\n[*] Semua bot direstart!")
            
        elseif choice == "4" then
            print("  Nomor bot: ")
            local bot_num = tonumber(io.read())
            if bot_num and bot_num >= 1 and bot_num <= Config.num_bots then
                StartBot(bot_num)
            else
                print("[!] Nomor bot tidak valid")
            end
            
        elseif choice == "5" then
            print("  Nomor bot: ")
            local bot_num = tonumber(io.read())
            if bot_num and bot_num >= 1 and bot_num <= Config.num_bots then
                StopBot(bot_num)
            else
                print("[!] Nomor bot tidak valid")
            end
            
        elseif choice == "6" then
            ShowStats()
            
        elseif choice == "7" then
            print("\n[*] Monitor loop dimulai (Ctrl+C untuk berhenti)")
            while true do
                os.sleep(Config.monitor_interval)
                MonitorBots()
                ShowStats()
            end
            
        elseif choice == "0" then
            print("\n[*] Keluar...")
            break
            
        else
            print("[!] Pilihan tidak valid")
        end
    end
end

-- Jalankan
Main()
