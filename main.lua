-- ============================================
-- GAG2 Auto Farm Script
-- Main Loader
-- ============================================

print([[
╔═══════════════════════════════════════════════════════════════╗
║           GAG2 AUTO FARM v1.0.0                               ║
║           Grow a Garden 2 Automation                          ║
╚═══════════════════════════════════════════════════════════════╝
]])

-- ============================================
-- LOAD CONFIG
-- ============================================

print("[*] Loading config...")
loadstring(game:HttpGet("https://raw.githubusercontent.com/fannyf123/GAG2-Farm/main/config.lua"))()

-- ============================================
-- LOAD MODULES
-- ============================================

print("[*] Loading modules...")

local modules = {}

-- Core Engine
print("  [1/6] Core Engine...")
modules.core = loadstring(game:HttpGet("https://raw.githubusercontent.com/fannyf123/GAG2-Farm/main/core.lua"))()

-- Pet System
print("  [2/6] Pet System...")
modules.pets = loadstring(game:HttpGet("https://raw.githubusercontent.com/fannyf123/GAG2-Farm/main/pets.lua"))()

-- Gear System
print("  [3/6] Gear System...")
modules.gear = loadstring(game:HttpGet("https://raw.githubusercontent.com/fannyf123/GAG2-Farm/main/gear.lua"))()

-- Mail System
print("  [4/6] Mail System...")
modules.mail = loadstring(game:HttpGet("https://raw.githubusercontent.com/fannyf123/GAG2-Farm/main/mail.lua"))()

-- Movement System
print("  [5/6] Movement System...")
modules.movement = loadstring(game:HttpGet("https://raw.githubusercontent.com/fannyf123/GAG2-Farm/main/movement.lua"))()

-- UI System
print("  [6/6] UI System...")
modules.ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/fannyf123/GAG2-Farm/main/ui.lua"))()

print("[*] All modules loaded!")

-- ============================================
-- INITIALIZATION
-- ============================================

print("\n[*] Initializing systems...")

-- Get core state
local coreState = modules.core.GetState()

-- Initialize modules
modules.pets.Init(coreState)
modules.gear.Init(coreState)
modules.mail.Init(coreState)
modules.movement.Init(coreState)
modules.ui.Init(coreState)

-- Create UI
modules.ui.CreateUI()

-- ============================================
-- GLOBAL STATE
-- ============================================

_G.GAGRunning = true
_G.GAGCore = modules.core
_G.GAGPets = modules.pets
_G.GAGGear = modules.gear
_G.GAGMail = modules.mail
_G.GAGMovement = modules.movement
_G.GAGUI = modules.ui

-- ============================================
-- PERFORMANCE SETTINGS
-- ============================================

local function ApplyPerformanceSettings()
    local perfConfig = _G.GAGConfig["Performance"]
    
    -- FPS Cap
    if perfConfig["FPS Cap"] > 0 then
        setfpscap(perfConfig["FPS Cap"])
        print("[*] FPS cap set to: " .. perfConfig["FPS Cap"])
    end
    
    -- Low Graphics
    if perfConfig["Low Graphics"] then
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 1e10
        
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
        end
        
        print("[*] Low graphics applied")
    end
    
    -- Remove Other Gardens
    if perfConfig["Remove Other Gardens"] then
        local gardens = workspace:FindFirstChild("Gardens") or workspace:FindFirstChild("Farms")
        if gardens then
            for _, garden in pairs(gardens:GetChildren()) do
                local owner = garden:FindFirstChild("Owner")
                if owner and owner.Value ~= Players.LocalPlayer.Name then
                    garden:Destroy()
                end
            end
            print("[*] Other gardens removed")
        end
    end
    
    -- Hide Crop Visuals
    if perfConfig["Hide Crop Visuals"] then
        local garden = workspace:FindFirstChild("Gardens") or workspace:FindFirstChild("Farms")
        if garden then
            for _, g in pairs(garden:GetChildren()) do
                local owner = g:FindFirstChild("Owner")
                if owner and owner.Value == Players.LocalPlayer.Name then
                    local plants = g:FindFirstChild("Plants") or g:FindFirstChild("Crops")
                    if plants then
                        for _, plant in pairs(plants:GetChildren()) do
                            for _, part in pairs(plant:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Transparency = 1
                                end
                            end
                        end
                    end
                end
            end
            print("[*] Crop visuals hidden")
        end
    end
end

-- ============================================
-- MAIN LOOP
-- ============================================

local function MainLoop()
    print("\n[*] Starting main farm loop...")
    print("[*] Press Ctrl+C or run _G.GAGRunning = false to stop")
    
    local updateCount = 0
    
    while _G.GAGRunning do
        local success, err = pcall(function()
            -- Update core systems
            modules.core.Update()
            modules.pets.Update()
            modules.gear.Update()
            modules.mail.Update()
            modules.movement.Update()
            modules.ui.Update()
            
            updateCount = updateCount + 1
        end)
        
        if not success then
            warn("[ERROR] " .. tostring(err))
        end
        
        -- Yield to prevent freezing
        task.wait(1)
    end
    
    print("\n[*] Farm loop stopped")
    print("[*] Total updates: " .. updateCount)
end

-- ============================================
-- STARTUP
-- ============================================

-- Apply performance settings
ApplyPerformanceSettings()

-- Start main loop
MainLoop()

-- ============================================
-- QUICK COMMANDS
-- ============================================

_G.GAG = {
    start = function() _G.GAGRunning = true end,
    stop = function() _G.GAGRunning = false end,
    toggle = function() _G.GAGRunning = not _G.GAGRunning end,
    sell = function() modules.core.SellAll() end,
    harvest = function() modules.core.HarvestAll() end,
    plant = function() modules.core.PlantAll() end,
    stats = function() 
        local state = modules.core.GetState()
        print("\n=== GAG2 Farm Stats ===")
        print("Sheckles: " .. (state.sheckles or 0))
        print("Status: " .. (_G.GAGRunning and "Running" or "Stopped"))
    end,
    ui = function(show)
        if show == nil then show = true end
        _G.GAGConfig["Misc"]["Show Stats"] = show
    end,
    console = function(show)
        if show == nil then show = true end
        _G.GAGConfig["Debug"]["Console"] = show
    end
}

print([[
============================================
  QUICK COMMANDS AVAILABLE
============================================
  Use _G.GAG.xxx() to access functions:
  
  _G.GAG.start()    - Start farm
  _G.GAG.stop()     - Stop farm
  _G.GAG.toggle()   - Toggle farm
  _G.GAG.sell()     - Sell all items
  _G.GAG.harvest()  - Harvest all plants
  _G.GAG.plant()    - Plant all seeds
  _G.GAG.stats()    - Show stats
  _G.GAG.ui(bool)   - Show/hide UI
  _G.GAG.console(bool) - Show/hide console
  
============================================
]])

print("[*] GAG2 Auto Farm ready!")
