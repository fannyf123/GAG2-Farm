-- ============================================
-- Roblox Ultra Light Mode
-- ============================================
-- Script untuk membuat Roblox SERINGAN mungkin
-- Khusus untuk multi-instance (VMOS/Multi Parallel)

-- ============================================
-- CONFIG ULTRA LIGHT
-- ============================================

local Config = {
    -- Ultra Settings
    FPS = 10,                     -- FPS sangat rendah
    RemoveEverything = true,      -- Hapus semua yang tidak perlu
    MinimalRendering = true,      // Render minimal
    DisableAllEffects = true,     // Matikan semua efek
    RemoveAllSounds = true,       // Hapus semua suara
    RemoveAllUI = true,           // Hapus semua UI kecuali script
    ReduceMemory = true,          // Minimalisir memory
}

-- ============================================
-- STEP 1: MATIKAN SEMUA RENDERING
-- ============================================

local function DisableAllRendering()
    print("[UltraLight] Disabling all rendering...")
    
    -- Matikan 3D rendering
    pcall(function()
        RunService:Set3dRenderingEnabled(false)
    end)
    
    -- Set quality ke minimum
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
    
    -- Matikan semua post-processing
    local Lighting = game:GetService("Lighting")
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 0
    Lighting.Brightness = 0
    Lighting.ClockTime = 0
    Lighting.Ambient = Color3.fromRGB(0, 0, 0)
    Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
    
    -- Hapus semua efek lighting
    for _, effect in pairs(Lighting:GetDescendants()) do
        if effect:IsA("PostEffect") then
            effect:Destroy()
        end
    end
    
    -- Set technology ke compatibility
    pcall(function()
        Lighting.Technology = Enum.Technology.Compatibility
    end)
    
    print("[UltraLight] Rendering disabled")
end

-- ============================================
-- STEP 2: HAPUS SEMUA OBJEK VISUAL
-- ============================================

local function RemoveAllVisuals()
    print("[UltraLight] Removing all visuals...")
    
    local count = 0
    local Workspace = game:GetService("Workspace")
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        -- Hapus partikel
        if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or 
           obj:IsA("Smoke") or obj:IsA("Sparkles") or
           obj:IsA("Explosion") or obj:IsA("Beam") or
           obj:IsA("Trail") or obj:IsA("Light") then
            obj:Destroy()
            count = count + 1
        end
        
        -- Hapus suara
        if obj:IsA("Sound") or obj:IsA("SoundGroup") then
            obj:Destroy()
            count = count + 1
        end
        
        -- Hapus texture/decal
        if obj:IsA("Decal") or obj:IsA("Texture") then
            obj:Destroy()
            count = count + 1
        end
        
        -- Hapus UI
        if obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") then
            obj:Destroy()
            count = count + 1
        end
        
        -- Hapus mesh (optional, bisa rusak game)
        -- if obj:IsA("SpecialMesh") then
        --     obj:Destroy()
        --     count = count + 1
        -- end
    end
    
    print("[UltraLight] Removed " .. count .. " visual objects")
end

-- ============================================
-- STEP 3: HAPUS PLAYER LAIN
-- ============================================

local function RemoveOtherPlayers()
    print("[UltraLight] Removing other players...")
    
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local count = 0
    
    -- Hapus karakter player lain
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                character:Destroy()
                count = count + 1
            end
            
            -- Hapus juga saat mereka respawn
            player.CharacterAdded:Connect(function(char)
                task.wait(0.1)
                char:Destroy()
            end)
        end
    end
    
    -- Hapus saat player baru join
    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function(char)
                task.wait(0.1)
                char:Destroy()
            end)
        end
    end)
    
    print("[UltraLight] Removed " .. count .. " other players")
end

-- ============================================
-- STEP 4: OPTIMASI MEMORY
-- ============================================

local function OptimizeMemory()
    print("[UltraLight] Optimizing memory...")
    
    -- Force garbage collection
    collectgarbage("collect")
    collectgarbage("collect")
    collectgarbage("collect")
    
    -- Set garbage collection mode
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 200)
    
    -- Bersihkan memory secara berkala
    spawn(function()
        while true do
            wait(30) -- Setiap 30 detik
            collectgarbage("collect")
        end
    end)
    
    print("[UltraLight] Memory optimized")
end

-- ============================================
-- STEP 5: OPTIMASI NETWORK
-- ============================================

local function OptimizeNetwork()
    print("[UltraLight] Optimizing network...")
    
    -- Reduce physics
    pcall(function()
        settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnvironmentalThrottle.Disabled
        settings().Physics.AllowSleep = true
        settings().Physics.ThrottleAdjustTime = math.huge
    end)
    
    -- Reduce rendering
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
    end)
    
    print("[UltraLight] Network optimized")
end

-- ============================================
-- STEP 6: HAPUS SEMUA UI
-- ============================================

local function RemoveAllUI()
    print("[UltraLight] Removing all UI...")
    
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local StarterGui = game:GetService("StarterGui")
    
    -- Matikan semua CoreGui
    pcall(function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
    end)
    
    -- Hapus semua GUI di PlayerGui
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in pairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                gui:Destroy()
            end
        end
    end
    
    print("[UltraLight] All UI removed")
end

-- ============================================
-- STEP 7: OPTIMASI TERRAIN
-- ============================================

local function OptimizeTerrain()
    print("[UltraLight] Optimizing terrain...")
    
    local Workspace = game:GetService("Workspace")
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    
    if terrain then
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
        terrain.WaterReflectance = 0
        terrain.WaterTransparency = 1
        terrain.Decoration = false
        terrain.AutoRefresh = false
    end
    
    print("[UltraLight] Terrain optimized")
end

-- ============================================
-- STEP 8: CONTINUOUS CLEANUP
-- ============================================

local function StartContinuousCleanup()
    print("[UltraLight] Starting continuous cleanup...")
    
    local Workspace = game:GetService("Workspace")
    
    -- Hapus objek baru yang muncul
    Workspace.DescendantAdded:Connect(function(obj)
        -- Hapus partikel baru
        if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or 
           obj:IsA("Smoke") or obj:IsA("Sparkles") then
            task.wait(0.05)
            obj:Destroy()
        end
        
        -- Hapus suara baru
        if obj:IsA("Sound") then
            task.wait(0.05)
            obj:Destroy()
        end
    end)
    
    print("[UltraLight] Continuous cleanup started")
end

-- ============================================
-- MAIN
-- ============================================

local function Main()
    print([[
╔═══════════════════════════════════════════════════════════════╗
║           ROBLOX ULTRA LIGHT MODE v1.0.0                      ║
║           Untuk Multi-Instance (VMOS/Multi Parallel)          ║
╚═══════════════════════════════════════════════════════════════╝
]])
    
    print("[UltraLight] Starting ultra optimization...")
    print("[UltraLight] WARNING: Semua visual akan dihapus!")
    print("")
    
    -- Jalankan semua optimasi
    DisableAllRendering()
    RemoveAllVisuals()
    RemoveOtherPlayers()
    OptimizeMemory()
    OptimizeNetwork()
    RemoveAllUI()
    OptimizeTerrain()
    StartContinuousCleanup()
    
    -- Set FPS
    pcall(function()
        setfpscap(Config.FPS)
    end)
    
    print("")
    print("[UltraLight] Semua optimasi selesai!")
    print("[UltraLight] FPS cap: " .. Config.FPS)
    print("[UltraLight] Roblox sekarang SANGAT ringan")
    print("")
    print("[UltraLight] Menunggu 3 detik sebelum load script...")
    task.wait(3)
    
    -- Load optimizer + GAG2 Farm
    print("[UltraLight] Loading optimizer...")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/fannyf123/GAG2-Farm/main/optimizer.lua"))()
end

-- Jalankan
Main()
