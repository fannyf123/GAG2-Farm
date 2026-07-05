-- ============================================
-- Roblox Performance Optimizer
-- ============================================
-- Script untuk membuat Roblox lebih ringan
-- Cocok untuk multi-instance / banyak bot

-- ============================================
-- CONFIG
-- ============================================

local Config = {
    -- Graphics
    LowGraphics = true,           -- Matikan semua efek grafis
    RemoveShadows = true,         -- Hapus shadow
    RemoveParticles = true,       -- Hapus partikel
    RemoveTextures = true,        -- Hapus texture
    ReduceDrawDistance = true,     -- Kurangi jarak render
    
    -- FPS
    FPSCap = 15,                  -- Limit FPS (0 = uncapped)
    DisableVSync = true,          -- Matikan VSync
    
    -- Memory
    ClearMemory = true,           -- Bersihkan memory berkala
    MemoryInterval = 60,          -- Interval bersihkan (detik)
    
    -- Objects
    RemoveOtherPlayers = true,    -- Hapus model player lain
    RemoveEffects = true,         -- Hapus efek visual
    RemoveDecals = true,          -- Hapus decal/stiker
    RemoveMeshes = false,         -- Hapus mesh (bisa rusak game)
    
    -- Network
    ReduceNetworkUsage = true,    -- Kurangi penggunaan network
}

-- ============================================
-- SERVICES
-- ============================================

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- ============================================
-- UTILITY
-- ============================================

local function Log(message)
    print("[Optimizer] " .. message)
end

local function SafeCall(func, ...)
    local success, err = pcall(func, ...)
    if not success then
        warn("[Optimizer Error] " .. tostring(err))
    end
    return success
end

-- ============================================
-- GRAPHICS OPTIMIZATION
-- ============================================

local function OptimizeGraphics()
    Log("Optimizing graphics...")
    
    -- Lighting
    if Config.RemoveShadows then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e10
        Lighting.FogStart = 0
        Lighting.Brightness = 0
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    end
    
    -- Terrain
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
        terrain.WaterReflectance = 0
        terrain.WaterTransparency = 0
        terrain.Decoration = false
    end
    
    -- Lighting effects
    for _, effect in pairs(Lighting:GetDescendants()) do
        if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or 
           effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or
           effect:IsA("ColorCorrectionEffect") or effect:IsA("DepthOfFieldEffect") then
            effect.Enabled = false
        end
    end
    
    -- Remove new lighting effects
    Lighting.Technology = Enum.Technology.Compatibility
    
    Log("Graphics optimized")
end

-- ============================================
-- FPS OPTIMIZATION
-- ============================================

local function OptimizeFPS()
    Log("Optimizing FPS...")
    
    -- Set FPS cap
    if Config.FPSCap > 0 then
        setfpscap(Config.FPSCap)
        Log("FPS cap set to: " .. Config.FPSCap)
    end
    
    -- Disable VSync
    if Config.DisableVSync then
        -- This is handled by the executor
    end
    
    -- Reduce rendering
    RunService:Set3dRenderingEnabled(false)
    
    Log("FPS optimized")
end

-- ============================================
-- MEMORY OPTIMIZATION
-- ============================================

local function ClearMemory()
    -- Force garbage collection
    collectgarbage("collect")
    collectgarbage("collect")
    
    -- Clear instances
    local count = 0
    
    -- Remove unused instances
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or 
           obj:IsA("Smoke") or obj:IsA("Sparkles") or
           obj:IsA("Explosion") or obj:IsA("Beam") then
            if Config.RemoveParticles then
                obj:Destroy()
                count = count + 1
            end
        end
    end
    
    if count > 0 then
        Log("Cleared " .. count .. " particle effects")
    end
end

local function StartMemoryCleanup()
    if not Config.ClearMemory then return end
    
    Log("Starting memory cleanup every " .. Config.MemoryInterval .. "s")
    
    spawn(function()
        while true do
            wait(Config.MemoryInterval)
            ClearMemory()
        end
    end)
end

-- ============================================
-- OBJECT REMOVAL
-- ============================================

local function RemoveUnnecessaryObjects()
    Log("Removing unnecessary objects...")
    
    local count = 0
    
    -- Remove particles
    if Config.RemoveParticles then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or 
               obj:IsA("Smoke") or obj:IsA("Sparkles") or
               obj:IsA("Explosion") or obj:IsA("Beam") or
               obj:IsA("Trail") then
                obj:Destroy()
                count = count + 1
            end
        end
    end
    
    -- Remove effects
    if Config.RemoveEffects then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Sound") or obj:IsA("SoundGroup") then
                obj:Destroy()
                count = count + 1
            end
        end
    end
    
    -- Remove decals
    if Config.RemoveDecals then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj:Destroy()
                count = count + 1
            end
        end
    end
    
    -- Remove other players
    if Config.RemoveOtherPlayers then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local character = player.Character
                if character then
                    character:Destroy()
                    count = count + 1
                end
            end
        end
    end
    
    Log("Removed " .. count .. " objects")
end

-- ============================================
-- TEXTURE OPTIMIZATION
-- ============================================

local function OptimizeTextures()
    if not Config.RemoveTextures then return end
    
    Log("Optimizing textures...")
    
    local count = 0
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            -- Reduce texture quality
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
            
            -- Remove special meshes
            local mesh = obj:FindFirstChildOfClass("SpecialMesh")
            if mesh and Config.RemoveMeshes then
                mesh:Destroy()
                count = count + 1
            end
        end
        
        -- Remove surface GUI
        if obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") then
            obj:Destroy()
            count = count + 1
        end
    end
    
    Log("Optimized " .. count .. " textures")
end

-- ============================================
-- DRAW DISTANCE
-- ============================================

local function ReduceDrawDistance()
    if not Config.ReduceDrawDistance then return end
    
    Log("Reducing draw distance...")
    
    -- Set render distance
    local camera = Workspace.CurrentCamera
    if camera then
        camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            -- Keep camera settings
        end)
    end
    
    -- Remove distant objects
    local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local count = 0
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj ~= rootPart then
                local distance = (obj.Position - rootPart.Position).Magnitude
                if distance > 500 then
                    obj:Destroy()
                    count = count + 1
                end
            end
        end
        Log("Removed " .. count .. " distant objects")
    end
end

-- ============================================
-- NETWORK OPTIMIZATION
-- ============================================

local function OptimizeNetwork()
    if not Config.ReduceNetworkUsage then return end
    
    Log("Optimizing network usage...")
    
    -- Reduce replication
    local success = pcall(function()
        settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnvironmentalThrottle.Disabled
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
    
    if success then
        Log("Network optimized")
    end
end

-- ============================================
-- UI OPTIMIZATION
-- ============================================

local function OptimizeUI()
    Log("Optimizing UI...")
    
    -- Disable core GUI elements
    SafeCall(function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
    end)
    
    -- Remove HUD
    SafeCall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, gui in pairs(playerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Name ~= "GAG2FarmUI" then
                    gui:Destroy()
                end
            end
        end
    end)
    
    Log("UI optimized")
end

-- ============================================
-- CONTINUOUS OPTIMIZATION
-- ============================================

local function StartContinuousOptimization()
    Log("Starting continuous optimization...")
    
    -- Remove new objects that spawn
    Workspace.DescendantAdded:Connect(function(obj)
        if Config.RemoveParticles then
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or 
               obj:IsA("Smoke") or obj:IsA("Sparkles") then
                task.wait(0.1)
                obj:Destroy()
            end
        end
        
        if Config.RemoveEffects then
            if obj:IsA("Sound") then
                task.wait(0.1)
                obj:Destroy()
            end
        end
    end)
    
    -- Remove other players when they join
    if Config.RemoveOtherPlayers then
        Players.PlayerAdded:Connect(function(player)
            if player ~= LocalPlayer then
                player.CharacterAdded:Connect(function(character)
                    task.wait(0.5)
                    character:Destroy()
                end)
            end
        end)
    end
    
    Log("Continuous optimization started")
end

-- ============================================
-- MAIN
-- ============================================

local function Main()
    print([[
╔═══════════════════════════════════════════════════════════════╗
║           ROBLOX PERFORMANCE OPTIMIZER v1.0.0                 ║
║           Untuk Multi-Instance / Banyak Bot                   ║
╚═══════════════════════════════════════════════════════════════╝
]])
    
    Log("Starting optimization...")
    
    -- Run optimizations
    SafeCall(OptimizeGraphics)
    SafeCall(OptimizeFPS)
    SafeCall(RemoveUnnecessaryObjects)
    SafeCall(OptimizeTextures)
    SafeCall(ReduceDrawDistance)
    SafeCall(OptimizeNetwork)
    SafeCall(OptimizeUI)
    SafeCall(StartMemoryCleanup)
    SafeCall(StartContinuousOptimization)
    
    Log("All optimizations applied!")
    Log("")
    Log("Tips:")
    Log("- FPS cap: " .. Config.FPSCap)
    Log("- Memory cleanup: every " .. Config.MemoryInterval .. "s")
    Log("- Run this script before GAG2 Farm script")
    Log("")
    
    -- Wait a moment then run GAG2 Farm
    task.wait(2)
    Log("Loading GAG2 Farm script...")
    
    loadstring(game:HttpGet("https://raw.githubusercontent.com/fannyf123/GAG2-Farm/master/main.lua"))()
end

-- Run
Main()
